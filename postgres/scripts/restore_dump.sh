#!/usr/bin/env bash

echo "Restoring backup.dump..."
pg_restore -d $POSTGRES_DB -U $POSTGRES_DB --clean --no-acl --no-owner /var/backups/backup.dump
echo "...done"
