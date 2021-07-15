#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh

verify_docker_and_memory
verify_installed "docker-compose"
check_docker_compose_version

# https://docs.docker.com/compose/profiles/
profile_control_center_command=""
if [ -z "$DISABLE_CONTROL_CENTER" ]
then
  profile_control_center_command="--profile control-center"
else
  log "🛑 control-center is disabled"
fi

profile_ksqldb_command=""
if [ -z "$DISABLE_KSQLDB" ]
then
  profile_ksqldb_command="--profile ksqldb"
else
  log "🛑 ksqldb is disabled"
fi

OLDDIR=$PWD

cd ${OLDDIR}/../../environment/2way-ssl/security
if [[ "$OSTYPE" == "darwin"* ]]
then
    # workaround for issue on linux, see https://github.com/vdesabou/kafka-docker-playground/issues/851#issuecomment-821151962
    chmod -R a+rw .
else
    # workaround for issue on linux, see https://github.com/vdesabou/kafka-docker-playground/issues/851#issuecomment-821151962
    sudo chmod -R a+rw .
fi
log "🔐 Generate keys and certificates used for SSL"
docker run --rm -v $PWD:/tmp vdesabou/kafka-docker-playground-connect:${CONNECT_TAG} /tmp/certs-create.sh
cd ${OLDDIR}/../../environment/2way-ssl

DOCKER_COMPOSE_FILE_OVERRIDE=$1
if [ -f "${DOCKER_COMPOSE_FILE_OVERRIDE}" ]
then
  docker-compose -f ../../environment/plaintext/docker-compose.yml -f ../../environment/2way-ssl/docker-compose.yml -f ${DOCKER_COMPOSE_FILE_OVERRIDE} down -v --remove-orphans
  docker-compose -f ../../environment/plaintext/docker-compose.yml -f ../../environment/2way-ssl/docker-compose.yml -f ${DOCKER_COMPOSE_FILE_OVERRIDE} ${profile_control_center_command} ${profile_ksqldb_command} up -d
  log "🎓To see the actual properties file, use ../../scripts/get-properties.sh <container>"
  log "⚡If you modify a docker-compose file and want to re-create the container(s), use this command:"
  log "⚡source ../../scripts/utils.sh && docker-compose -f ../../environment/plaintext/docker-compose.yml -f ../../environment/2way-ssl/docker-compose.yml -f ${DOCKER_COMPOSE_FILE_OVERRIDE} ${profile_control_center_command} ${profile_ksqldb_command} up -d"
else
  docker-compose -f ../../environment/plaintext/docker-compose.yml -f ../../environment/2way-ssl/docker-compose.yml down -v --remove-orphans
  docker-compose -f ../../environment/plaintext/docker-compose.yml -f ../../environment/2way-ssl/docker-compose.yml ${profile_control_center_command} ${profile_ksqldb_command} up -d
  log "🎓To see the actual properties file, use ../../scripts/get-properties.sh <container>"
  log "⚡If you modify a docker-compose file and want to re-create the container(s), use this command:"
  log "⚡source ../../scripts/utils.sh && docker-compose -f ../../environment/plaintext/docker-compose.yml -f ../../environment/2way-ssl/docker-compose.yml ${profile_control_center_command} ${profile_ksqldb_command} up -d"
fi

cd ${OLDDIR}

if [ "$#" -ne 0 ]
then
    shift
fi
../../scripts/wait-for-connect-and-controlcenter.sh $@

display_jmx_info