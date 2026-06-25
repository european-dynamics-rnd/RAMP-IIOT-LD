#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <tenant> <entity> [stateChangeKey] [lastN]"
    echo "  tenant: NGSILD-Tenant value"
    echo "  entity: entity/sensorID"
    echo "  lastN: optional number of latest temporal entries to request (default: 5)"
    echo "  attrsKey: optional filter for specific attrs"
    echo "  example: $0 openiot urn:ngsi-ld:AD007:AD007 heel_seat_pressing_machine 5"
    exit 1
fi

TENANT="$1"
sensorID="$2"
LAST_N="${3}"
ATTRS_KEY="${4}"

TEMPORAL_ENDPOINT='http://localhost:'"${MINTAKA_PORT}"'/temporal/entities/'"${sensorID}"''
echo $ATTRS_KEY
if [ -n "$ATTRS_KEY" ]; then
    curl -s -G -X GET "$TEMPORAL_ENDPOINT" \
    -H 'NGSILD-Tenant: '"${TENANT}"'' \
    -H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
    -d 'attrs='"${ATTRS_KEY}"'' \
    -d 'lastN='"${LAST_N}"'' | jq
else
    curl -s -G -X GET "$TEMPORAL_ENDPOINT" \
    -H 'NGSILD-Tenant: '"${TENANT}"'' \
    -H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
    -d 'lastN='"${LAST_N}"'' | jq
fi
