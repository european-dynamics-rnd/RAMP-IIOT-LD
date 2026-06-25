#!/bin/bash
set -e
export $(cat ../../.env | grep "#" -v)

curl -X GET 'http://localhost:'"${ORION_LD_PORT}"'/ngsi-ld/v1/entities/urn:ngsi-ld:ed:ieq-001' \
    -H 'NGSILD-Tenant: test_federation'  |jq