#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)



if [ $# -eq 0 ]; then
    type="PM_SENSOR"
    echo "No type as input. Providing data for type:PM_SENSOR"
else
    type="$1"
fi


# curl -X GET  'http://'"${HOST}"':'"${ORION_LD_PORT}"'/version' |jq 
echo -e 'Orion-lD needs to run on localhost'


curl -s -G -X GET  'http://localhost:'"${ORION_LD_PORT}"'/ngsi-ld/v1/entities' \
-H 'NGSILD-Tenant: openiot' \
-H 'NGSILD-Path: /' \
-H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
-d 'type='"${type}"'' |jq  


# -d 'type=PM_SENSOR' |jq  

 # -H 'NGSILD-Tenant: openiot' \
# -H 'NGSILD-Path: /' \