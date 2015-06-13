#!/bin/bash
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null


DOCKER_COMPOSE=$( which docker-compose )

[ -x "$DOCKER_COMPOSE" ] || DOCKER_COMPOSE=$(which fig)

if [ ! -x "$DOCKER_COMPOSE" ]; then
  echo "docker-compose or fig are not found or not executable"
  exit 1
fi

$DOCKER_COMPOSE stop
$DOCKER_COMPOSE rm -v

echo "Destroying InfluxDB data"

rm -rf ${SCRIPTPATH}/data
mkdir ${SCRIPTPATH}/data
rm -f ${SCRIPTPATH}/etc/docker/certs.d/*

