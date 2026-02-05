#!/bin/bash
export PORT_HTTP=8080
export PORT_HTTPS=8443
if [ -z "$COMPOSE_PROJECT_NAME" ];
then
  cat << EOS
  You have run $0 without specifying the env variable \$COMPOSE_PROJECT_NAME.
  You need to specify the compose project name
  Do it as follows:
  COMPOSE_PROJECT_NAME=my-restore-project-name $0 $@
EOS
  exit 1
fi

if [[ $COMPOSE_PROJECT_NAME = "oberdocker" ]] ; then
    echo You want to restore to the real compose project '$COMPOSE_PROJECT_NAME' on this computer?
    echo This will overwrite the current data with the backup and they might no be recoverable
    read -p "Are you sure? Y or N?: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
        exit 0
    fi
  else
    echo The compose project name is set to '$COMPOSE_PROJECT_NAME'.
    echo The data will be written to volumes prefixed with $COMPOSE_PROJECT_NAME
    read -p "Should we proceed? Y or N?: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
        exit 0
    fi
fi

NO_RESTORE=false docker compose \
    --file docker-compose.yml \
    --file docker-compose-backup.yml \
    run volumerize restore || exit 1

if [[ $COMPOSE_PROJECT_NAME = "oberdocker" ]];
  then
    echo restore is completed.
  else
    echo I can start up this environment on port $PORT_HTTP and PORT_HTTPS
    read -p "Should i do so? Y or N?: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
        echo you can do it yourself with the following command:
        echo COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME docker compose -f docker-compose.yml up
        exit 0
    fi
    docker compose -f docker-compose.yml up
fi

