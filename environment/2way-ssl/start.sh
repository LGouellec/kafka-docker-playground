#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh
verify_installed "jq"
verify_installed "docker-compose"
verify_installed "keytool"

OLDDIR=$PWD

cd ${OLDDIR}/../../environment/2way-ssl/security

echo -e "\033[0;33mGenerate keys and certificates used for SSL\033[0m"
./certs-create.sh > /dev/null 2>&1

cd ${OLDDIR}/../../environment/2way-ssl

DOCKER_COMPOSE_FILE_OVERRIDE=$1
if [ -f "${DOCKER_COMPOSE_FILE_OVERRIDE}" ]
then

  docker-compose -f ../../environment/2way-ssl/docker-compose.yml -f ${DOCKER_COMPOSE_FILE_OVERRIDE} down -v
  docker-compose -f ../../environment/2way-ssl/docker-compose.yml -f ${DOCKER_COMPOSE_FILE_OVERRIDE} up -d
else
  docker-compose -f ../../environment/2way-ssl/docker-compose.yml down -v
  docker-compose -f ../../environment/2way-ssl/docker-compose.yml up -d
fi

cd ${OLDDIR}

shift
../../scripts/wait-for-connect-and-controlcenter.sh $@