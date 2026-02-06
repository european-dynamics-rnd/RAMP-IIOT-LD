#!/bin/bash
cd demo_data
# import building
./demo1-import-data-building

# add testing data
for i in {1..10}
do
  ./generate_measurements_pm_sensor.sh pm_sensor-001
done
