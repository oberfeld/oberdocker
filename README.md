# Docker-compose setup to run nextcloud for oberfeld

## Containers

This docker-compose setup consist of the following containers:
- nextcloud: The container running the nextcloud app
- db: MariaDb container to store nextclouds data 
- elasticsearch: The container running the elasticsearch index for the fulltextsearch
- proxy: Ngin-X server to automatically route different domains/virtual host to the corresponding container ips
- adminer: GUI for the db
- letsencrypt-companion: companion for proxy to download certificates for https encryptions
- portainer: admin gui for the entire setup.
- volumerize: Volume backup container. As configured now

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
- `docker-local.sh`: for local works
- `docker-prod.sh`: for the prod environment.
Both files need the acctual docker-compose commands, such as `up` or `down` to be appended as cli options. e.g. `./docker-local.sh up -d` or `./docker-prod.sh down`.

## Manual interaction when installing:

### (local only) set host names
To be able to access the different application you need to choose different domains for this, as 
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
create `.env` file with the following content (values need to be changed accordingly)
```ini
#Password for mysql in the db containers
MYSQL_ROOT_PASSWORD=my_root_pwd

#database and user and pwd for nextcould database 
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=my_pwd

#Nextcloud admin user name (this will only be used for initial setup)
NEXTCLOUD_ADMIN_USER=oberuser
#DNS name for nextcloud (will only be used for the initial setup)
NEXTCLOUD_VIRTUAL_HOST=chischte.oberfeld.be
#DNS name for nextcloud. Use it empty locally
NEXTCLOUD_LETSENCRYPT_HOST=
#Password for admin user (will only be considered the first time nextcloud is installed)
NEXTCLOUD_ADMIN_PASSWORD=my_nextcloud_admin_pwd

#DNS name for adminer
ADMINER_MARIA_VIRTUAL_HOST=adminer.oberfeld.be
#DNS name for adminer. Use it empty locally
ADMINER_MARIA_LETSENCRYPT_HOST=

#DNS name for portainer
PORTAINER_VIRTUAL_HOST=portainer.oberfeld.be
#DNS name for portainer. Use it empty locally
PORTAINER_LETSENCRYPT_HOST=
PORTAINER_PASSWORD_HASH=$2y$05$ksEgrHIJdw1gR5ZySLafDeWH2NIHl20rkva9r4oK54goI/yT1jI4S

#Max memory for elasticsearch process. Need to be high in prod (>10)
ELASTICSEARCH_MEM_IN_MB=1000

#Password used to encrypt the backup
BACKUP_PASSWORD=very secure password
#Target where the backup should be saved to (duplicity option)
BACKUP_TARGET=pexpect+scp://backuphost

```
### Auth keys for Backup
The SSH key that are used to authenticate the user at the backup target host
need to placed in `./keys/id_rsa`.
You can use the command
```bash
$> mkdir keys && ssh-keygen -f keys/id_rsa -N ""
``` 
Then copy the content of the file `./keys/id_rsa.pub` to the backup-target's file `.ssh/authorized_keys`.

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
