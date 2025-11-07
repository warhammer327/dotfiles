#!/bin/bash

# Configuration
WATCH_DIR="/home/$USER/calibre_library"
S3_PATH="s3://s3-general-backup-warhammer327/calibre-library-backup"
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

# Sync function
sync_now() {
  # Atomic lock - only one sync can run
  if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    return
  fi

  log "Starting S3 sync..."

  aws s3 sync "$WATCH_DIR" "$S3_PATH" \
    --profile "$AWS_PROFILE" \
    --exact-timestamps \
    --exclude ".caltrash/*" \
    --delete \
    --only-show-errors \
    --sse AES256 2>&1 | tee -a "$LOG_FILE"

  result=${PIPESTATUS[0]}

  # Remove lock
  rmdir "$LOCK_FILE"

  if [ $result -eq 0 ]; then
    log "Sync completed successfully"
  else
    log "Sync failed (exit code: $result)"
  fi
}

# Cleanup
cleanup() {
  log "Shutting down"
  rmdir "$LOCK_FILE" 2>/dev/null
  pkill -P $$ 2>/dev/null
  exit 0
}

trap cleanup INT TERM

# Startup
log "=== Starting Calibre S3 Sync Monitor ==="
log "Watching: $WATCH_DIR"

if [ ! -d "$WATCH_DIR" ]; then
  log "ERROR: Directory not found"
  exit 1
fi

# Clean up
rmdir "$LOCK_FILE" 2>/dev/null

# Monitor
inotifywait -m -r -e create,delete,moved_to,moved_from \
  --exclude '\.caltrash|metadata\.db' \
  --format '%w%f %e' \
  "$WATCH_DIR" 2>&1 | while read -r line; do

  # Skip setup messages
  [[ $line == *"Watches established"* ]] && log "Ready" && continue
  [[ $line == *"Setting up watches"* ]] && continue

  log "Change detected"

  # Kill any existing timer (restart the countdown)
  pkill -P $$ sleep 2>/dev/null

  # Start new timer - waits 60 seconds from NOW
  (
    sleep $WAIT_TIME
    sync_now
  ) &
done
