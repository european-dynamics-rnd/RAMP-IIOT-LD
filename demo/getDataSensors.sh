#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)



if [ $# -lt 2 ]; then
    echo "Usage: $0 <tenant> <type>"
    echo "  tenant: NGSILD-Tenant value"
    echo "  type: Entity type"
    exit 1
fi

TENANT="$1"
type="$2"


# curl -X GET  'http://'"${HOST}"':'"${ORION_LD_PORT}"'/version' |jq 
echo -e 'Orion-lD needs to run on localhost'


curl -s -G -X GET  'http://localhost:'"${ORION_LD_PORT}"'/ngsi-ld/v1/entities' \
-H 'NGSILD-Tenant: '"${TENANT}"'' \
-H 'NGSILD-Path: /' \
-H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
-d 'type='"${type}"'' |jq  
