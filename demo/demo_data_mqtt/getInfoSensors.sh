#!/bin/bash
#

#

set -e
export $(cat ../../.env | grep "#" -v)



if [ $# -eq 0 ]; then
    type="ENERGY_METER"
    echo "No type as input. Providing data for type:ENERGY_METER"
else
    type="$1"
fi


# curl -X GET  'http://'"${HOST}"':'"${ORION_LD_PORT}"'/version' |jq 


curl -s -G -X GET  'http://'"${HOST}"':'"${ORION_LD_PORT}"'/ngsi-ld/v1/entities' \
-H 'NGSILD-Tenant: openiot' \
-H 'NGSILD-Path: /' \
-H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Accept: application/ld+json' \
-d 'type='"${type}"'' |jq  


# -d 'type=PM_SENSOR' |jq  

 # -H 'NGSILD-Tenant: openiot' \
# -H 'NGSILD-Path: /' \