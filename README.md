# Docker-compose setup to run nextcloud for oberfeld

## Containers

This docker-compose setup consist of the following containers:
- nextcloud: The container running the nextcloud app
- db: MariaDb container to store nextclouds data
- cron: Runs Nextcloud background jobs every 5 minutes
- elasticsearch: The container running the elasticsearch index for the fulltextsearch
- proxy: Ngin-X server to automatically route different domains/virtual host to the corresponding container ips
- adminer: GUI for the db
- letsencrypt-companion: companion for proxy to download certificates for https encryptions
- collabora: Collabora Online for editing documents in the browser
- portainer: admin gui for the entire setup.
- volumerize: Volume backup container. As configured now, it will backup to an S3 Bucket
- eml-converter: Automatically converts .eml email files to PDF. Watches the Nextcloud data directory for new .eml files and creates a corresponding .pdf file using [email-to-pdf-converter](https://github.com/nickrussler/email-to-pdf-converter).

### Docker compose files
The docker-compose setup is split into several docker-compose files. This allows to start parts of the setup in specific environments.
- `docker-compose.yml`: This is the main docker-compose file. It contains nextcloud, db, proxy, and portainer. It't the most simple version and is ideal to be run on the local machine.
- `docker-compose-adminer.yml`: contains the adminer container. This is only needed, if you want to do work on the db directly.
- `docker-compose-backup.yml`: This adds the volumerize container to the setup. It will backup the volumens `db` and `nextcloud`. This is only needed for prod.
- `docker-compose-es.yml`: This adds the elasticsearch container to index the nextcloud files and to allow fulltextsearch. This is only needed in prod.
- `docker-compose-letsencrypt.yml`: This adds the let'sencrypt companion container for the nginx proxy. Such that every container, that is exposed by the proxy, gets its own certificate for its domain.
- `docker-compose-restore.yml`: This container allows to restore from the backup. For more information see below.

### Shellscripts
There are some shell scripts, that pack together the docker-compose files for a given environment.
- `oberdocker-local.sh`: for local works
- `oberdocker-prod.sh`: for the prod environment.
Both files need the actual docker compose commands, such as `up` or `down` to be appended as cli options. e.g. `./oberdocker-local.sh up -d` or `./oberdocker-prod.sh down`.

## Manual interaction when installing:

### (local only) set host names
To be able to access the different application you need to choose different domains for these, as 
the proxy redirect based on the hostname used to call the request.

On linux and mac, you may add those hosts in the `/etc/hosts` file, such as 
```
127.0.0.1   localhost
127.0.0.1   greenbox
127.0.0.1   portainer
127.0.0.1   adminer
```
### set vm.max_map_count
elasticsearch needs vm.max_map_count to be set to a min of 262144
see here [https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html]

### .env File
Create `.env` file with the following content. Values marked with `<CHANGE_ME>` must be replaced with your own values.

```ini
# ===========================================
# DATABASE (MariaDB)
# ===========================================
MYSQL_ROOT_PASSWORD=<CHANGE_ME>              # Root password for MySQL
MYSQL_DATABASE=nextcloud                      # Database name (can keep as-is)
MYSQL_USER=nextcloud                          # Database user (can keep as-is)
MYSQL_PASSWORD=<CHANGE_ME>                   # Password for MYSQL_USER

# ===========================================
# NEXTCLOUD
# ===========================================
NEXTCLOUD_ADMIN_USER=<CHANGE_ME>             # Admin username (only used on initial setup), e.g. oberuser
NEXTCLOUD_ADMIN_PASSWORD=<CHANGE_ME>         # Admin password (only used on initial setup)
NEXTCLOUD_VIRTUAL_HOST=<CHANGE_ME>           # DNS name, e.g. chischte.oberfeld.be
NEXTCLOUD_LETSENCRYPT_HOST=                   # Same as above for prod, empty for local

# ===========================================
# ADMINER (Database GUI)
# ===========================================
ADMINER_MARIA_VIRTUAL_HOST=<CHANGE_ME>       # DNS name, e.g. adminer.oberfeld.be
ADMINER_MARIA_LETSENCRYPT_HOST=               # Same as above for prod, empty for local

# ===========================================
# COLLABORA (Online document editing)
# ===========================================
COLLABORA_VIRTUAL_HOST=<CHANGE_ME>           # DNS name, e.g. collabora.oberfeld.be
COLLABORA_LETSENCRYPT_HOST=                   # Same as above for prod, empty for local
COLLABORA_ADMIN_USER=<CHANGE_ME>             # Collabora admin username
COLLABORA_ADMIN_PASSWORD=<CHANGE_ME>         # Collabora admin password

# ===========================================
# PORTAINER (Docker admin GUI)
# ===========================================
PORTAINER_VIRTUAL_HOST=<CHANGE_ME>           # DNS name, e.g. portainer.oberfeld.be
PORTAINER_LETSENCRYPT_HOST=                   # Same as above for prod, empty for local
PORTAINER_PASSWORD_HASH=<CHANGE_ME>          # Generate with: htpasswd -nbB admin 'password' | cut -d: -f2

# ===========================================
# ELASTICSEARCH (Full-text search)
# ===========================================
ELASTICSEARCH_MEM_IN_MB=1000                  # Memory limit (use >10000 for prod)
ELASTICSEARCH_PASSWORD=<CHANGE_ME>           # Password for elastic user

# ===========================================
# BACKUP (S3)
# ===========================================
BACKUP_PASSWORD=<CHANGE_ME>                  # GPG encryption passphrase for backups
BACKUP_AWS_ACCESS_KEY_ID=<CHANGE_ME>         # AWS access key ID
BACKUP_AWS_SECRET_ACCESS_KEY=<CHANGE_ME>     # AWS secret access key
# Note: S3 bucket name is configured in docker-compose-backup.yml (default: oberfeld)
```

### Plugins for Nextcloud
Install the following Apps in nextcloud
- Full text search
- Full text search - Elasticsearch Platform
- Full text search - Files

Set the configuration values for Fulltextsearch (Volltextsuche) in elasticsearch
- Suchplattform: Elasticsearch
- Adresse des Servlets: http://elasticsearch:9200/
- index: nextcloud (vorschlag)

### Configuration
After Installation / Updates, readd our custom NextCloud configuration:
- `docker exec -i --user www-data oberdocker_nextcloud_1 php occ config:system:set default_language --value="de"`
- `docker exec -i --user www-data oberdocker_nextcloud_1 php occ config:system:set default_phone_region --value="CH"`
- `docker exec -i --user www-data oberdocker_nextcloud_1 php occ config:system:set skeletondirectory --value=""`
- `docker exec -i --user www-data oberdocker_nextcloud_1 php occ config:system:set templatedirectory --value=""`


## Backup to S3
The database and the nextcloud files (data and code) are backed up (volumes `db` and `nextcloud`).
This is done by the container `backup` using [BorgBackup](https://www.borgbackup.org/) + [borgmatic](https://torsion.org/borgmatic/).

### Features
- **Incremental & deduplicated** backups (like Nextcloud AIO uses)
- Daily backups at 2am
- Encrypted with `BACKUP_PASSWORD`
- Retention: 7 daily, 4 weekly, 6 monthly backups
- Local Borg repository synced to S3 via rclone

### Setup
See [BACKUP-SETUP.md](BACKUP-SETUP.md) for initial setup instructions.

### Run Backup Manually
```bash
docker exec oberdocker-backup-1 borgmatic --stats -v 1
```

### List Available Backups
```bash
docker exec oberdocker-backup-1 borgmatic list
```

### Restore
To restore from a backup:
```bash
# Stop Nextcloud first
docker stop oberdocker-nextcloud-1

# List available archives
docker exec -it oberdocker-backup-1 borgmatic list

# Extract a specific archive (interactive)
docker exec -it oberdocker-backup-1 borgmatic extract --archive latest

# Or use the restore compose file for interactive shell
docker compose -f docker-compose-restore.yml run --rm restore
# Inside container:
borgmatic list
borgmatic extract --archive <archive-name> --destination /mnt/source
```

### Sync to S3
The backup automatically syncs to S3 after each backup. To manually sync:
```bash
docker exec oberdocker-backup-1 rclone sync /mnt/borg-repository s3:oberfeld/borg-backup
```

### Download from S3 (disaster recovery)
If you need to restore on a new server:
```bash
docker exec oberdocker-backup-1 rclone sync s3:oberfeld/borg-backup /mnt/borg-repository
```

**Warning:** Restoring will overwrite current data in the volumes.