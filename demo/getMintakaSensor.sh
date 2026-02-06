#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)

if [ $# -lt 2 ]; then
    echo "Usage: $0 <tenant> <entity>"
    echo "  tenant: NGSILD-Tenant value"
    echo "  entity: entity/sensorID"
    exit 1
fi

TENANT="$1"
sensorID="$2"


curl -s -G -X GET  'http://localhost:'"${MINTAKA_PORT}"'/temporal/entities/'"${sensorID}"'' \
-H 'NGSILD-Tenant: '"${TENANT}"'' \
-H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-d 'lastN=5' |jq  

