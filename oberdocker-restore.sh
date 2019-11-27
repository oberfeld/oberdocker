#!/bin/bash
export PORT_HTTP=8080
export PORT_HTTPS=8443
docker-compose \
    -f docker-compose.yml \
    -f docker-compose-restore.yml \
    "$@"
