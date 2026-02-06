#!/bin/bash
# 
#

set -e
export $(cat ../.env | grep "#" -v)

if [ "$HOST" == "localhost" ]; then
  INSECURE=' --insecure '
else
  INSECURE=''
fi


if [ $# -lt 2 ]; then
    echo "Usage: $0 <tenant> <entity>"
    echo "  tenant: NGSILD-Tenant value"
    echo "  entity: entity/sensorID"
    exit 1
fi

TENANT="$1"
sensorID="$2"


./getTokenMintaka.sh
token=$(cat "tokenMintaka.txt")


KONG_URL='https://'"${HOST}"':'"${KONG_PORT}"'/keycloak-mintaka'

curl -s $INSECURE -G -X GET  ''"${KONG_URL}"'/temporal/entities/'"${sensorID}"'' \
-H 'NGSILD-Tenant: '"${TENANT}"'' \
-H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Authorization: Bearer '"${token}"' ' \
-d 'lastN=5' |jq  

