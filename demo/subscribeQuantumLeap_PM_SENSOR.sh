#!/bin/bash
#

set -e
export $(cat ../.env | grep "#" -v)

curl -L -X POST 'http://localhost:'"${ORION_LD_PORT}"'/ngsi-ld/v1/subscriptions/' \
-H 'Content-Type: application/ld+json' \
-H 'NGSILD-Tenant: openiot' \
--data-raw '{
  "description": "Notify me of all changes of PM_SENSOR",
  "type": "Subscription",
  "entities": [{"type": "PM_SENSOR"}],
"watchedAttributes": ["pm25","temperature", "relativeHumidity"],
  "notification": {
    "attributes": ["pm25","temperature", "relativeHumidity"],
    "format": "normalized",
    "endpoint": {
      "uri": "'"${SUBSCRIBE_URL}"'",
      "accept": "application/json",
      "receiverInfo": [{
                "key": "Fiware-Service",
                "value": "openiot"
      }]
    }
  },
   "@context": "'"${CONTEXT}"'"
  }'

  curl -X GET 'http://localhost:'"${ORION_LD_PORT}"'/ngsi-ld/v1/subscriptions/' -H 'NGSILD-Tenant: openiot' |jq .
  
