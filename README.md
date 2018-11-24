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
```

Install the following Apps in nextcloud
- Full text search
- Full text search - Elasticsearch Platform
- Full text search - Files

Set the configuration values for Fulltextsearch (Volltextsuche) in elasticsearch
- Suchplattform: Elasticsearch
- Adresse des Servlets: http://elasticsearch:9200/
- index: nextcloud (vorschlag)