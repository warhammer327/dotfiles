#!/bin/bash

# Configuration
CALIBRE_DIR="/home/$USER/calibre_library"
MUSIC_DIR="/home/$USER/Music"
CALIBRE_S3_PATH="s3://s3-general-backup-warhammer327/calibre-library-backup"
MUSIC_S3_PATH="s3://s3-general-backup-warhammer327/audio"
AWS_PROFILE="library_manager"
LOG_FILE="$HOME/.local/share/calibre-s3-sync.log"
WAIT_TIME=60 # Wait 1 minute after last change
LOCK_FILE="/tmp/calibre-sync.lock"

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Simple logging
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Sync function for Calibre
sync_calibre() {
  if ! mkdir "${LOCK_FILE}_calibre" 2>/dev/null; then
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
  rmdir "${LOCK_FILE}_calibre"

  if [ $result -eq 0 ]; then
    log "Calibre sync completed successfully"
  else
    log "Calibre sync failed (exit code: $result)"
  fi
}

# Sync function for Music
sync_music() {
  if ! mkdir "${LOCK_FILE}_music" 2>/dev/null; then
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
  rmdir "${LOCK_FILE}_music"

  if [ $result -eq 0 ]; then
    log "Music sync completed successfully"
  else
    log "Music sync failed (exit code: $result)"
  fi
}

# Cleanup
cleanup() {
  log "Shutting down"
  rmdir "${LOCK_FILE}_calibre" 2>/dev/null
  rmdir "${LOCK_FILE}_music" 2>/dev/null
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
rmdir "${LOCK_FILE}_calibre" 2>/dev/null
rmdir "${LOCK_FILE}_music" 2>/dev/null

# Monitor Calibre directory
inotifywait -m -r -e create,delete,moved_to,moved_from \
  --exclude '\.caltrash|metadata\.db' \
  --format 'CALIBRE:%w%f %e' \
  "$CALIBRE_DIR" 2>&1 &

# Monitor Music directory
inotifywait -m -r -e create,delete,moved_to,moved_from \
  --format 'MUSIC:%w%f %e' \
  "$MUSIC_DIR" 2>&1 &

# Process events from both monitors
while read -r line; do
  # Skip setup messages
  [[ $line == *"Watches established"* ]] && log "Ready" && continue
  [[ $line == *"Setting up watches"* ]] && continue

  if [[ $line == CALIBRE:* ]]; then
    log "Calibre change detected"

    # Kill any existing calibre timer
    pkill -f "sleep.*calibre_timer" 2>/dev/null

    # Start new timer for Calibre
    (
      sleep $WAIT_TIME
      sync_calibre
    ) &

  elif [[ $line == MUSIC:* ]]; then
    log "Music change detected"

    # Kill any existing music timer
    pkill -f "sleep.*music_timer" 2>/dev/null

    # Start new timer for Music
    (
      sleep $WAIT_TIME
      sync_music
    ) &
  fi
done
