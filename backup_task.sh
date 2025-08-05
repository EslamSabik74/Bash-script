#!/usr/bin/bash

DATE=$(date +%Y-%m-%d_%H-%M)
SNAPSHOT_FILE="snapshot.file"
TARGET_DIR="/home"
BACKUP_DIR="/var/backup_script"
LOG_DIR="/var/log/backup_script"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz"
LOGFILE="$LOG_DIR/incremental_backup_$DATE.log"

EMAIL="esabik@gmail.com"
FROM_EMAIL="esabik@gmail.com"
SUBJECT_SUCCESS="Backup Succeeded on $DATE"
SUBJECT_FAIL="Backup Failed on $DATE"

tar --listed-incremental=$SNAPSHOT_FILE -czvf "$BACKUP_FILE" "$TARGET_DIR" > "$LOGFILE" 2>&1
STATUS=$?

if [ $STATUS -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
    echo "Backup completed successfully on $DATE. File: $BACKUP_FILE" | s-nail -s "$SUBJECT_SUCCESS" -r "$FROM_EMAIL" "$EMAIL"
else
    echo "Backup FAILED on $DATE. Check log: $LOGFILE" | s-nail -s "$SUBJECT_FAIL" -r "$FROM_EMAIL" "$EMAIL"
fi

find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -exec rm -f {} \;

cd "$LOG_DIR"
LOG_COUNT=$(ls -1 *.log 2>/dev/null | wc -l)
if [ "$LOG_COUNT" -gt 5 ]; then
  ls -1tr *.log | head -n -5 | xargs -d '\n' rm -f --
fi
