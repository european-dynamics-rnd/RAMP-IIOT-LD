#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../.env"

set -a
source <(grep -v '^#' "$ENV_FILE" | grep -v '^\s*$')
set +a
set -e

generate_random_number() {
  # Generate a random integer between 100 and 405 (inclusive)
  random_integer=$((RANDOM % 306 + 100))

  # Convert the integer to a floating-point number with one decimal place
  random_float="$((random_integer / 10)).$((random_integer % 10))"

  echo $random_float
}

# Default values
TENANT="openiot"

if [ "$#" -eq 1 ]; then
  echo "generating random measurements for " ${1}
  SENSOR=${1}
  PM25=$(generate_random_number)
  T=$(generate_random_number)
  RH=$(generate_random_number)
elif [ "$#" -eq 2 ]; then
  echo "generating random measurements for " ${1} " with tenant " ${2}
  SENSOR=${1}
  TENANT=${2}
  PM25=$(generate_random_number)
  T=$(generate_random_number)
  RH=$(generate_random_number)
elif [ "$#" -eq 4 ]; then
  SENSOR=${1}
  PM25=${2}
  T=${3}
  RH=${4}
elif [ "$#" -eq 5 ]; then
  SENSOR=${1}
  PM25=${2}
  T=${3}
  RH=${4}
  TENANT=${5}
else
  echo "Usage: $0 <sensor_id> [pm25] [temperature] [humidity] [tenant]"
  echo "  sensor_id: Device identifier (e.g., pm_sensor-001)"
  echo "  pm25: PM2.5 value (optional, random if not provided)"
  echo "  temperature: Temperature value (optional, random if not provided)"
  echo "  humidity: Relative humidity value (optional, random if not provided)"
  echo "  tenant: NGSILD-Tenant value (optional, default: openiot)"
  echo ""
  echo "Examples:"
  echo "  $0 pm_sensor-001"
  echo "  $0 pm_sensor-001 openiot"
  echo "  $0 pm_sensor-001 11.5 22.3 75.8"
  echo "  $0 pm_sensor-001 11.5 22.3 75.8 openiot"
  echo ""
  echo "generating random measurements for pm_sensor-001 with default tenant"
  SENSOR="pm_sensor-001"
  PM25=$(generate_random_number)
  T=$(generate_random_number)
  RH=$(generate_random_number)
fi

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create entity ID
ENTITY_ID="urn:ngsi-ld:PM_SENSOR:${SENSOR}"

echo -e 'Send measurements of device' "${SENSOR}"' to Orion LD: PM2.5: '"${PM25}"', Temperature: '"${T}"', RH: '"${RH}"

# Generate JSON-LD payload
JSON_LD_PAYLOAD=$(cat <<EOF
[{
  "id": "${ENTITY_ID}",
  "type": "PM_SENSOR",
  "pm25": {
    "type": "Property",
    "value": ${PM25},
    "unitCode": "GQ",
    "observedAt": "${TIMESTAMP}"
  },
  "temperature": {
    "type": "Property",
    "value": ${T},
    "unitCode": "CEL",
    "observedAt": "${TIMESTAMP}"
  },
  "relativeHumidity": {
    "type": "Property",
    "value": ${RH},
    "unitCode": "P1",
    "observedAt": "${TIMESTAMP}"
  },
  "dateObserved": {
    "type": "Property",
    "value": {
      "@type": "DateTime",
      "@value": "${TIMESTAMP}"
    }
  },
  "@context": [
    "${CONTEXT}",
    "${CORE_CONTEXT}"
  ]
}]
EOF
)
# echo $JSON_LD_PAYLOAD
# Post to Orion LD
curl -iL -X POST "http://${HOST}:${ORION_LD_PORT}/ngsi-ld/v1/entityOperations/upsert" \
-H "NGSILD-Tenant: ${TENANT}" \
-H "Content-Type: application/ld+json" \
-d "${JSON_LD_PAYLOAD}"

echo -e "\n"