#!/bin/bash
COMPOSE_PROJECT_NAME=oberdocker docker-compose \
    -f docker-compose.yml \
    -f docker-compose-backup.yml \
    "$@"
#    -f docker-compose-es.yml \
