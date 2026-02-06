#!/bin/bash
#
# Setup Uptime Kuma monitors for all RAMP-IoT services.
#
# Prerequisites:
#   pip install uptime-kuma-api
#
# Usage:
#   ./setup_uptime_kuma.sh
#
set -e
export $(cat ../.env | grep "#" -v)

UPTIME_KUMA_URL="http://${HOST}:${UPTIME_KUMA_PORT}"
UPTIME_KUMA_USER="${UPTIME_KUMA_USER:-admin}"
UPTIME_KUMA_PASSWORD="${UPTIME_KUMA_PASSWORD:-Pa55w0rd!}"

echo "Waiting for Uptime Kuma to be ready at ${UPTIME_KUMA_URL}..."
until curl -sf "${UPTIME_KUMA_URL}" > /dev/null 2>&1; do
  echo "  Uptime Kuma not ready yet, retrying in 5s..."
  sleep 5
done
echo "Uptime Kuma is up!"

# Check if pip package is available
if ! python3 -c "import uptime_kuma_api" 2>/dev/null; then
  echo "Installing uptime-kuma-api Python package..."
  pip install uptime-kuma-api
fi

python3 "$(dirname "$0")/setup_uptime_kuma.py" \
  --url "${UPTIME_KUMA_URL}" \
  --username "${UPTIME_KUMA_USER}" \
  --password "${UPTIME_KUMA_PASSWORD}" \
  --orion-port "${ORION_LD_PORT}" \
  --mongo-port "${MONGO_DB_PORT}" \
  --mintaka-port "${MINTAKA_PORT}" \
  --timescale-port "${TIMESCALE_PORT}" \
  --keycloak-port "8080" \
  --kong-port "${KONG_PORT}" \
  --iota-mqtt-north-port "${IOTA_MQTT_NORTH_PORT}" \
  --mqtt-port "${IOTA_MQTT_PORT}" \
  --prometheus-port "9090" \
  --alertmanager-port "9093"

echo ""
echo "Setup complete! Access Uptime Kuma at: ${UPTIME_KUMA_URL}"
echo "  Username: ${UPTIME_KUMA_USER}"
echo "  Password: ${UPTIME_KUMA_PASSWORD}"
