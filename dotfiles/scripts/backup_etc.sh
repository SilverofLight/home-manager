#!/bin/bash

# Source directory to back up
SOURCE_DIR="/etc"
# Backup storage directory
BACKUP_DIR="/home/silver/Templates"
# Backup file name (including timestamp)
DATE=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="$BACKUP_DIR/etc_backup_$DATE.tar.gz"

# Create the backup storage directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform the backup
echo "Backing up /etc to $BACKUP_FILE ..."
tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" .

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Backup successful! File stored at $BACKUP_FILE"
else
  echo "Backup failed!"
fi
