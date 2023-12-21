#!/bin/bash
# 
# to have both SSO and type use ./getMintakaSensorsToken.sh SSO SENSOR_ID

#

set -e
export $(cat ../.env | grep "#" -v)

if [ "$HOST" == "localhost" ]; then
  INSECURE=' --insecure '
else
  INSECURE=''
fi

# 
if [ "$1" = "SSO" ]; then
  echo "Redicecting to ramp.eu for login"
  python3 getTokenMintaka_oauth2.py 
else
  ./getTokenMintaka.sh
fi

token=$(cat "tokenMintaka.txt")

if [ $# -eq 0 ]; then
    sensorID="urn:ngsi-ld:PM_SENSOR:pm_sensor-001"
    echo "No type as input. Providing data for urn:ngsi-ld:PM_SENSOR:pm_sensor-001"
elif [ $# -eq 1 ]; then
  if [ "$1" == "SSO" ]; then
    sensorID="urn:ngsi-ld:PM_SENSOR:pm_sensor-001"
    echo "No type as input. Providing data for urn:ngsi-ld:PM_SENSOR:pm_sensor-001"
  else
    sensorID="$1"
  fi
elif [ $# -eq 2 ]; then
  sensorID="$2"
fi


KONG_URL='https://'"${HOST}"':'"${KONG_PORT}"'/keycloak-mintaka'

curl -s $INSECURE -G -X GET  ''"${KONG_URL}"'/temporal/entities/'"${sensorID}"'' \
-H 'NGSILD-Tenant: openiot' \
-H 'Link: <'"${CONTEXT}"'>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"' \
-H 'Authorization: Bearer '"${token}"' ' \
-d 'lastN=5' |jq  

