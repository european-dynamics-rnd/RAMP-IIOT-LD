#!/bin/bash
cd demo_data
# import building
./demo1-import-data-building
# Import PM sensor service
./provisioning_service.sh json_configurations/service_PM_SENSOR.json
# provition PM senspr
./provisioning_device.sh json_configurations/device_pm_sensor-001.json
# add testing data
for i in {1..10}
do
  ./generate_measurements_pm_sensor.sh
done
