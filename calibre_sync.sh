#!/bin/bash

# Configuration
CALIBRE_DIR="/home/$USER/calibre_library"
MUSIC_DIR="/home/$USER/Music"
CALIBRE_S3_PATH="s3://s3-general-backup-warhammer327/calibre-library-backup"
MUSIC_S3_PATH="s3://s3-general-backup-warhammer327/audio"
AWS_PROFILE="library_manager"
LOG_FILE="$HOME/.local/share/calibre-s3-sync.log"
WAIT_TIME=60 # Wait 1 minute after last change
CALIBRE_TIMER_PID=""
MUSIC_TIMER_PID=""

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Simple logging
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Sync function for Calibre
sync_calibre() {
  local lock_file="/tmp/calibre-sync-calibre.lock"

  if ! mkdir "$lock_file" 2>/dev/null; then
    return
  fi

  log "Starting Calibre S3 sync..."

  aws s3 sync "$CALIBRE_DIR" "$CALIBRE_S3_PATH" \
    --profile "$AWS_PROFILE" \
    --exact-timestamps \
    --exclude ".caltrash/*" \
    --delete \
    --only-show-errors \
    --sse AES256 2>&1 | tee -a "$LOG_FILE"

  result=${PIPESTATUS[0]}
  rmdir "$lock_file"

  if [ $result -eq 0 ]; then
    log "Calibre sync completed successfully"
  else
    log "Calibre sync failed (exit code: $result)"
  fi
}

# Sync function for Music
sync_music() {
  local lock_file="/tmp/calibre-sync-music.lock"

  if ! mkdir "$lock_file" 2>/dev/null; then
    return
  fi

  log "Starting Music S3 sync..."

  aws s3 sync "$MUSIC_DIR" "$MUSIC_S3_PATH" \
    --profile "$AWS_PROFILE" \
    --exact-timestamps \
    --delete \
    --only-show-errors \
    --sse AES256 2>&1 | tee -a "$LOG_FILE"

  result=${PIPESTATUS[0]}
  rmdir "$lock_file"

  if [ $result -eq 0 ]; then
    log "Music sync completed successfully"
  else
    log "Music sync failed (exit code: $result)"
  fi
}

# Cleanup
cleanup() {
  log "Shutting down"
  rmdir "/tmp/calibre-sync-calibre.lock" 2>/dev/null
  rmdir "/tmp/calibre-sync-music.lock" 2>/dev/null
  pkill -P $$ 2>/dev/null
  exit 0
}

trap cleanup INT TERM

# Startup
log "=== Starting Multi-Directory S3 Sync Monitor ==="
log "Watching Calibre: $CALIBRE_DIR"
log "Watching Music: $MUSIC_DIR"

if [ ! -d "$CALIBRE_DIR" ]; then
  log "ERROR: Calibre directory not found"
  exit 1
fi

if [ ! -d "$MUSIC_DIR" ]; then
  log "ERROR: Music directory not found"
  exit 1
fi

# Clean up any stale locks
rmdir "/tmp/calibre-sync-calibre.lock" 2>/dev/null
rmdir "/tmp/calibre-sync-music.lock" 2>/dev/null

# Create named pipes for communication
FIFO="/tmp/calibre-sync-fifo-$$"
mkfifo "$FIFO"
exec 3<>"$FIFO"
rm "$FIFO"

# Monitor Calibre directory
(
  inotifywait -m -r -e create,delete,moved_to,moved_from \
    --exclude '\.caltrash|metadata\.db' \
    --format 'CALIBRE' \
    "$CALIBRE_DIR" 2>/dev/null
) >&3 &

# Monitor Music directory
(
  inotifywait -m -r -e create,delete,moved_to,moved_from \
    --format 'MUSIC' \
    "$MUSIC_DIR" 2>/dev/null
) >&3 &

log "Monitors started, ready for changes"

# Process events
while read -r -u 3 event; do
  if [[ $event == CALIBRE ]]; then
    log "Calibre change detected"

    # Kill existing calibre timer if running
    if [ -n "$CALIBRE_TIMER_PID" ] && kill -0 "$CALIBRE_TIMER_PID" 2>/dev/null; then
      kill "$CALIBRE_TIMER_PID" 2>/dev/null
    fi

    # Start new timer
    (
      sleep $WAIT_TIME
      sync_calibre
    ) &
    CALIBRE_TIMER_PID=$!

  elif [[ $event == MUSIC ]]; then
    log "Music change detected"

    # Kill existing music timer if running
    if [ -n "$MUSIC_TIMER_PID" ] && kill -0 "$MUSIC_TIMER_PID" 2>/dev/null; then
      kill "$MUSIC_TIMER_PID" 2>/dev/null
    fi

    # Start new timer
    (
      sleep $WAIT_TIME
      sync_music
    ) &
    MUSIC_TIMER_PID=$!
  fi
done
