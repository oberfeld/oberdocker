# Backup Setup Guide

Initial setup for the BorgBackup + rclone backup system.

## Prerequisites

1. **Set environment variables** in your `.env` file:
   ```
   BACKUP_PASSWORD=<your-secure-passphrase>
   BACKUP_AWS_ACCESS_KEY_ID=<your-s3-access-key>
   BACKUP_AWS_SECRET_ACCESS_KEY=<your-s3-secret-key>
   ```

2. **Build and start the backup container**:
   ```bash
   docker compose -f docker-compose-backup.yml up -d --build
   ```

## Initialize Borg Repository

Run this **once** to create the encrypted Borg repository:

```bash
docker exec -it oberdocker-backup-1 borgmatic init --encryption repokey
```

> ⚠️ **Important**: Save the encryption passphrase! Without it, backups cannot be restored.

## Backup the Encryption Key

Export and store the repository key securely:

```bash
docker exec -it oberdocker-backup-1 borg key export /mnt/borg-repository /tmp/borg-key.txt
docker cp oberdocker-backup-1:/tmp/borg-key.txt ./borg-key-backup.txt
```

Store `borg-key-backup.txt` in a safe location (password manager, offline storage).

## Test the Backup

Run a manual backup to verify everything works:

```bash
docker exec -it oberdocker-backup-1 borgmatic create --verbosity 1
```

Check that S3 sync completed:

```bash
docker exec -it oberdocker-backup-1 rclone ls s3:oberfeld/borg-backup
```

## Verify Scheduled Backups

Backups run automatically at **2:00 AM daily**. Check logs:

```bash
docker logs oberdocker-backup-1
```

## Restore

See [README.md](README.md#restore) for restore instructions.
