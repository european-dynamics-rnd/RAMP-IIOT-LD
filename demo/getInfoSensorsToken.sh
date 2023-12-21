#!/bin/bash
#
# to have both SSO and type use ./getInfoSensorsToken.sh SSO TYPE
#

set -e
export $(cat ../.env | grep "#" -v)

if [ "$HOST" == "localhost" ]; then
  INSECURE=' --insecure '
else
  INSECURE=''
fi

if [ "$1" = "SSO" ]; then
  echo "Redicecting to ramp.eu for login"
  python3 getToken_oauth2.py
else
  ./getToken.sh
fi

token=$(cat "token.txt")

if [ $# -eq 0 ]; then
  type="PM_SENSOR"
  echo "No type as input. Providing data for type:PM_SENSOR"
elif [ $# -eq 1 ]; then
  if [ "$1" == "SSO" ]; then
    type="PM_SENSOR"
    echo "No type as input. Providing data for type:PM_SENSOR"
  else
    type="$1"
  fi
elif [ $# -eq 2 ]; then
  type="$2"
fi

# curl -X GET  'http://'"${HOST}"':'"${ORION_LD_PORT}"'/version' |jq

KONG_URL='https://'"${HOST}"':'"${KONG_PORT}"'/keycloak-orion'
# echo $KONG_URL
curl -s $INSECURE -G -X GET ''"${KONG_URL}"'/ngsi-ld/v1/entities' \
  -H 'NGSILD-Tenant: openiot' \
  -H 'NGSILD-Path: /' \
  -H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
  -H 'Accept: application/ld+json' \
  -H 'Authorization: Bearer '"${token}"' ' \
  -d 'type='"${type}"'' | jq

# -d 'type=PM_SENSOR' |jq

# -H 'NGSILD-Tenant: openiot' \
# -H 'NGSILD-Path: /' \
