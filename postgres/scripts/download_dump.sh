#!/usr/bin/env bash

echo "Downloading backup.dump from S3..."
aws s3api get-object --bucket "near-me-db-backups" --key "db_backup/backup.dump" "/var/backups/backup.dump"
echo "...done"
