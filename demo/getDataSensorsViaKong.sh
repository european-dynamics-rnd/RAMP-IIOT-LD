#!/bin/bash
#


set -e
export $(cat ../.env | grep "#" -v)

if [ "$HOST" == "localhost" ]; then
  INSECURE=' --insecure '
else
  INSECURE=''
fi

if [ $# -lt 2 ]; then
    echo "Usage: $0 <tenant> <type>"
    echo "  tenant: NGSILD-Tenant value"
    echo "  type: Entity type"
    exit 1
fi

TENANT="$1"
type="$2"


./getOrionToken.sh
token=$(cat "token.txt")

KONG_URL='https://'"${HOST}"':'"${KONG_PORT}"'/keycloak-orion'
# echo $KONG_URL
curl -s $INSECURE -G -X GET ''"${KONG_URL}"'/ngsi-ld/v1/entities' \
  -H 'NGSILD-Tenant: '"${TENANT}"'' \
  -H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
  -H 'Accept: application/ld+json' \
  -H 'Authorization: Bearer '"${token}"' ' \
  -d 'type='"${type}"'' | jq
