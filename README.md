# Docker-compose setup to run nextcloud for oberfeld

## Containers

This setup consist of the following containers:
- nextcloud: The container running the nextcloud app
- db: MariaDb container to store nextclouds data 
- elasticsearch: The container running the elasticsearch index for the fulltextsearch
- proxy: Ngin-X server to automatically route different domains/virtual host to the corresponding container ips
- letsencrypt-companion: companion for proxy to download certificates for https encryptions
- adminer: admin gui for the DB
- portainer: admin gui for the entire setup.

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
#if "true", will fetch certs from letsencrypt. Use "false" locally 
USE_LETSENCRYPT="false"

#Password for mysql in the mysql containers
MYSQL_ROOT_PASSWORD=my_root_pwd
MYSQL_PASSWORD=my_pwd

#DNS name for nextcloud
NEXTCLOUD_VIRTUAL_HOST=greenbox.oberfeld.be
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