#!/bin/bash
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

[ -e $SCRIPTPATH/env.sh ] && source $SCRIPTPATH/env.sh

HOSTNAME=${HOSTNAME:-docker00.example.com}
CERTS_PATH=${SCRIPTPATH}/etc/docker/certs.d/

BOOT2DOCKER=$(which boot2docker)
ENVSUBST=$(which envsubst)
if [ ! -x "$ENVSUBST" ]; then
  echo -e "ERROR: envsubst not found.  Cannot replace variables in docker-compose.yml.tmpl!"
  echo -e "ERROR: Please install the gettext package."
  echo -e "INFO:  On OS X, you can use:"
  echo -e "       brew install gettext"
  echo -e "       ln -s $(brew --cellar gettext)/$(ls -1t $(brew --cellar gettext)/ | head -n1 )/bin/envsubst /usr/local/bin/envsubst"
  echo -e "Exiting..."
  exit 1
fi

ANSIBLE=$( which ansible )
if [ -x "$BOOT2DOCKER" ]; then
BOOT2DOCKER_HOSTNAME=${HOSTNAME}
  if [ ! -x "$ANSIBLE" ]; then
   echo -e "WARN: ansible binary not found.  Cannot edit /etc/hosts to add boot2docker IP with hostname: ${BOOT2DOCKER_HOSTNAME} \nWARN: You may want to do this manually"
  else
    echo "$ANSIBLE found!"
    echo "I will add your boot2docker IP to /etc/hosts for convenience"
    echo "Please enter your sudo password to edit /etc/hosts:"
  fi

  # ^(.*) registry\.$( echo "$BOOT2DOCKER_HOSTNAME" | sed 's/[^[:alnum:]_-]/\\&/g' )$'
  ansible localhost -i ${SCRIPTPATH}/hosts  -m lineinfile -a "dest=/etc/hosts insertafter='EOF' line='$(boot2docker ip) ${BOOT2DOCKER_HOSTNAME}'"   -vvvv  --sudo --ask-sudo-pass
  ansible localhost -i ${SCRIPTPATH}/hosts  -m lineinfile -a "dest=/etc/hosts insertafter='EOF' line='$(boot2docker ip) registry.${BOOT2DOCKER_HOSTNAME}'"   -vvvv  --sudo --ask-sudo-pass
  ansible localhost -i ${SCRIPTPATH}/hosts  -m lineinfile -a "dest=/etc/hosts insertafter='EOF' line='$(boot2docker ip) registry-ui.${BOOT2DOCKER_HOSTNAME}'"   -vvvv  --sudo --ask-sudo-pass
fi

[ -e "$CERTS_PATH" ] || mkdir -p $CERTS_PATH
pushd $CERTS_PATH

# Avoid problematic filenames for certs & keys
# replace '*.' with 'star_'
# replace '.' with '_'
# For example: A wildcard cert should end up being named: star_example_com.crt
CERT_NAME="${CERT_NAME:-$HOSTNAME}"
export CERT_NAME

wildcard_cert=$(echo "$CERT_NAME" | grep -c '\*')

if [ $wildcard_cert -gt 0 ]; then
  CERT_NAME="${CERT_NAME/\*\./star_}"
  CERT_NAME="${CERT_NAME/\./_}"
fi

${SCRIPTPATH}/gen-cert.sh "${CERT_NAME}"
eval $(grep '^password=' ${SCRIPTPATH}/gen-cert.sh)


cp $CERT_NAME.key $CERT_NAME.key.enc
openssl rsa -in $CERT_NAME.key.enc -out $CERT_NAME.key -passin pass:$password
openssl x509 -req -days 365 -in $CERT_NAME.csr -sha256 -signkey $CERT_NAME.key -out $CERT_NAME.crt

## Specific to InfluxDB SSL
## Reference: https://github.com/tutumcloud/tutum-docker-influxdb#ssl-support
awk 1 ORS='\\n' $CERT_NAME.crt $CERT_NAME.key > $CERT_NAME.crt.key.concat
export CERT_NAME
export SSL_CERT="$(cat $CERT_NAME.crt.key.concat)"
cat ${SCRIPTPATH}/docker-compose.yml.tmpl | envsubst > ${SCRIPTPATH}/docker-compose.yml
## END InfluxDB SSL Cert munging

popd

DOCKER_COMPOSE=$( which docker-compose )

[ -x "$DOCKER_COMPOSE" ] || DOCKER_COMPOSE=$(which fig)

if [ ! -x "$DOCKER_COMPOSE" ]; then
  echo "docker-compose or fig are not found or not executable"
  exit 1
fi


[ -n "$BOOT2DOCKER" ] && eval $(boot2docker shellinit bash)

# Ensure certs are fully written to disk so no race conditions
sync

$DOCKER_COMPOSE -f ${SCRIPTPATH}/docker-compose.yml up -d
