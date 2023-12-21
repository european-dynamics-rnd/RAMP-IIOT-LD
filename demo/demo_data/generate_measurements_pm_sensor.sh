#!/bin/bash


export $(cat ../../.env | grep "#" -v)
set -e

generate_random_number() {
  # Generate a random integer between 100 and 405 (inclusive)
  random_integer=$((RANDOM % 306 + 100))

  # Convert the integer to a floating-point number with one decimal place
  random_float="$((random_integer / 10)).$((random_integer % 10))"

  echo $random_float
}

if [ "$#" -eq 1 ]; then
  echo "generating random measurements for " ${1}
  SENSOR=${1}
  PM25=$(generate_random_number)
  T=$(generate_random_number)
  RH=$(generate_random_number)
elif [ "$#" -ne 4 ]; then
  echo "I need 4 arguments to run. ie ./generate_measurements_pm_senspr.sh pm_sensor-001 11 22 7"
  echo "generating random measurements for pm_sensor-001"
  SENSOR="pm_sensor-001"
  PM25=$(generate_random_number)
  T=$(generate_random_number)
  RH=$(generate_random_number)
else
  SENSOR=${1}
  PM25=${2}
  T=${3}
  RH=${4}
fi
echo -e 'Send measurements of device' "${SENSOR}"': PM2.5: '"${PM25}"', Temperature: '"${T}"', RH: '"${RH}" 

curl -s -L -X POST 'http://localhost:'"${IOTA_SOUTH_PORT}"'/iot/json?k='"${PM_SENSOR_APIKEY}"'&i='"${SENSOR}"''  > /dev/null \
-H 'Content-Type: application/json' \
--data '{"pm_25":'"${PM25}"' ,"t": '"${T}"', "rh": '"${RH}"'}'