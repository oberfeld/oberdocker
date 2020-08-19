#!/bin/bash

projectname=$1
time=$2

if [ "oberdocker" != $projectname ]
then
    if [ "restore" != $projectname ]
    then
        echo "project name, (1. argument) must be either 'oberdocker' or 'restore'"
        exit 1
    else 
        echo "restoring to a separate docker environment with name 'restore'"
    fi
else
    echo "restoring to production"
fi

if [ -z $time ]
then
    echo "You need to specify the date to restore as 2. parameter in the format 2019-11-04T16:13:00+02:00"
fi

COMPOSE_PROJECT_NAME=$projectname ./oberdocker-restore.sh up -d
docker exec restore restore --time $time