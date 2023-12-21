#!/bin/bash


export $(cat ../../.env | grep "#" -v)
set -e

# HOST=bf-micocraft-server.eurodyn.com

generate_random_number() {
  # Generate a random integer between 100 and 405 (inclusive)
  random_integer=$((RANDOM % 306 + 100))

  # Convert the integer to a floating-point number with one decimal place
  random_float="$((random_integer / 10)).$((random_integer % 10))"

  echo $random_float
}

if [ "$#" -eq 2 ]; then
  echo "generating random measurements for " ${1}
  SENSOR=${1}
  TOPIC=${2}
  v=$(generate_random_number)
  a=$(generate_random_number)
  e=$(generate_random_number)
elif [ "$#" -ne 5 ]; then
  echo "I need 5 arguments to run. ie ./generate_measurements_energy_meter.sh energymeter-001 2uv4s40d59ovesffsdf 220 1.1 3242"
  echo "generating random measurements for energymeter-001"
  SENSOR="energymeter-001"
  TOPIC="2uv4s40d59ovesffsdf"
  v=$(generate_random_number)
  a=$(generate_random_number)
  e=$(generate_random_number)
else
  SENSOR=${1}
  TOPIC=${2}
  v=${3}
  a=${4}
  e=${5}
fi
echo -e 'Send measurements of device' "${SENSOR}"': Voltage: '"${v}"', Current: '"${a}"', Total energy consumption: '"${e}" 
# echo -e 'v|'"${v}"',a|'"${a}"',e|'"${e}"''
echo -e '/'"${TOPIC}"'/'"${SENSOR}"'/attrs'

# mosquitto_pub -h ${HOST} -p ${IOTA_MQTT_PORT} -m 'v|'"${v}"'|a|'"${a}"'|e|'"${e}"'' -t '/'"${TOPIC}"'/'"${SENSOR}"'/attrs'
mosquitto_pub -h ${HOST} -p ${IOTA_MQTT_PORT} -u ramp-iot -P 'PmnMBT@c2Hf62Y4%sAJf' -m '{"v":'"${v}"',"a":'"${a}"',"e":'"${e}"'} ' -t '/'"${TOPIC}"'/'"${SENSOR}"'/attrs'

