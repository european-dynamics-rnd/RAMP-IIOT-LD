#!/bin/bash
#
# Simulate realistic sensor traffic by sending random measurements
# at random intervals (2–20 seconds) for a given number of steps.
#
# Usage:
#   ./simulate_sensor_traffic.sh [steps] [sensor_id] [min_delay] [max_delay]
#
#   steps:     Number of measurements to send (default: 100)
#   sensor_id: Sensor identifier (default: pm_sensor-001)
#   min_delay: Minimum delay in seconds between steps (default: 2)
#   max_delay: Maximum delay in seconds between steps (default: 20)
#
# Examples:
#   ./simulate_sensor_traffic.sh
#   ./simulate_sensor_traffic.sh 50
#   ./simulate_sensor_traffic.sh 200 pm_sensor-002
#   ./simulate_sensor_traffic.sh 100 pm_sensor-001 5 30
#
set -e

STEPS=${1:-100}
SENSOR=${2:-pm_sensor-001}
MIN_DELAY=${3:-2}
MAX_DELAY=${4:-20}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Sensor Traffic Simulator ==="
echo "  Sensor:    ${SENSOR}"
echo "  Steps:     ${STEPS}"
echo "  Delay:     ${MIN_DELAY}–${MAX_DELAY}s (random)"
echo "  Started:   $(date)"
echo "================================="
echo ""

for i in $(seq 1 "${STEPS}"); do
  # Random delay between MIN_DELAY and MAX_DELAY
  DELAY=$(( RANDOM % (MAX_DELAY - MIN_DELAY + 1) + MIN_DELAY ))

  echo "[${i}/${STEPS}] Sending measurement (next in ${DELAY}s)..."
  "${SCRIPT_DIR}/demo_data/generate_measurements_pm_sensor.sh" "${SENSOR}"

  # Don't sleep after the last step
  if [ "${i}" -lt "${STEPS}" ]; then
    sleep "${DELAY}"
  fi
done

echo ""
echo "=== Simulation complete ==="
echo "  Sent ${STEPS} measurements for ${SENSOR}"
echo "  Finished: $(date)"
