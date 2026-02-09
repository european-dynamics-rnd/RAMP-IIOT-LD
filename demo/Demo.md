# Demo RAMP-IoT-LD

A demo has been prepared for the user to familiarize with the different components.
The main components are:
1. [Orion-LD](https://github.com/FIWARE/context.Orion-LD) as Context Broker. Listen to port 1026.
2. [Mintaka](https://github.com/FIWARE/mintaka) as NGSI-LD temporal retrieval API. Listen to port 8089.
3. [Keycloak](https://www.keycloak.org/) as single sign-on with identity and access management. Listen to 8443. Self-signed certificates with admin:Pa55w0rd.
4. [Kong](https://github.com/FIWARE/kong-plugins-fiware) as PEP (Policy Enforcement Point) proxy for Orion-LD and Mintaka. Listen to port 443. See [kong.yaml](../kong-config/kong.yaml) for more details about the implementation.
5. [TimescaleDB](https://www.timescale.com/) to store all entities received by Orion-LD.
6. [FIWARE IoT JSON Agent](https://github.com/telefonicaid/iotagent-json) to provide measurements.

![RAMP IIoT LD demo Architecture](img/demo_diagram.png)

The demo can run on every Linux system. The following tools need to be installed: ```docker-compose, curl, bash, jq``` 
jq is used for the formatting of the return json from Orion-LD and Mintaka.

## Docker
To run RAMP-IoT use: ```./service start``` on the main folder. The first time it will need to download all Docker images ~10minutes depending on internet speed. Then open another terminal to [continue](#demo).

The main docker-compose file(docker-compose.yml) includes additional compose files for specific services.
1. temporal.yml. Service for Mintaka and TimescaleDB.
2. keycloak.yml. Service for Keycloak and Kong.
3. iot-agent-json.yml. Service for IoT Agent.

**IMPORTANT** The database of Keycloak (volume ramp-keycloak-db) has been initialized with default values for the purposes of the demo. To disable it comment line " - ${PWD}/keycloak/create_tables.sql:/docker-entrypoint-initdb.d/create_tables.sql" on the [keycloak.yml](../keycloak.yml), remove the volume (```docker volume rm ramp_iiot_ramp-keycloak-db```), restart docker-compose and follow the instructions [here](#keycloak) for setup.

## Demo with JSON-LD
A demo script has been developed. See [demo_data](./demo_data/) for more details.

Run `./setup_demo.sh` to create a building entity and a Particulate Matter sensor (`urn:ngsi-ld:PM_SENSOR:pm_sensor-001`) with 10 random measurements.

The script generates NGSI-LD compliant JSON-LD payloads and posts them directly to Orion-LD via the `/ngsi-ld/v1/entityOperations/upsert` endpoint. Each measurement includes:
- **pm25** — PM2.5 concentration (unit: GQ)
- **temperature** — Temperature (unit: CEL)
- **relativeHumidity** — Relative Humidity (unit: P1)
- **observedAt** — ISO 8601 timestamp for each property

### Example JSON-LD Payload

```json
[{
  "id": "urn:ngsi-ld:PM_SENSOR:pm_sensor-001",
  "type": "PM_SENSOR",
  "pm25": {
    "type": "Property",
    "value": 32.9,
    "unitCode": "GQ",
    "observedAt": "2026-02-06T15:05:24Z"
  },
  "temperature": {
    "type": "Property",
    "value": 29.4,
    "unitCode": "CEL",
    "observedAt": "2026-02-06T15:05:24Z"
  },
  "relativeHumidity": {
    "type": "Property",
    "value": 31.1,
    "unitCode": "P1",
    "observedAt": "2026-02-06T15:05:24Z"
  },
  "dateObserved": {
    "type": "Property",
    "value": {
      "@type": "DateTime",
      "@value": "2026-02-06T15:05:24Z"
    }
  },
  "@context": [
    "http://ramp_iiot-ld-context/merge_data_model.jsonld",
    "http://ramp_iiot-ld-context/ngsi-ld-core-context-v1.7.jsonld"
  ]
}]
```

### Sending Individual Measurements

Use `generate_measurements_pm_sensor.sh` to send a single measurement:
```bash
# Random values
cd demo_data
./generate_measurements_pm_sensor.sh pm_sensor-001

# Specific values: sensor_id pm25 temperature humidity
./generate_measurements_pm_sensor.sh pm_sensor-001 11.5 22.3 75.8

# With a custom tenant
./generate_measurements_pm_sensor.sh pm_sensor-001 11.5 22.3 75.8 mytenant
```

### Simulating Continuous Traffic

Use `simulate_sensor_traffic.sh` to send measurements at random intervals (2–20s) simulating realistic sensor traffic:
```bash
# Default: 100 steps for pm_sensor-001
./simulate_sensor_traffic.sh

# Custom: 50 steps for pm_sensor-002
./simulate_sensor_traffic.sh 50 pm_sensor-002

# Custom delays: 200 steps, 5–30s apart
./simulate_sensor_traffic.sh 200 pm_sensor-001 5 30
```

### Multi-Tenancy

Orion-LD supports multi-tenancy through the `NGSILD-Tenant` header. Each tenant has its own isolated data space in the databases (MongoDB and TimescaleDB). This is useful when:
- Multiple applications or departments share the same Orion-LD instance but need data isolation.
- Different IoT deployments (e.g., different buildings or sites) need separate data stores.
- Access control and data governance require logical separation between datasets.

The demo uses the `openiot` tenant by default. You can specify a different tenant as an argument to the measurement scripts. When querying data, use the same tenant value in all `getDataSensors.sh` and `getMintakaSensor.sh` commands.

### Query Orion-LD to get the last values

You can use the following commands:
1. ```./getOrionVersion.sh``` : To get the version of the Orion-LD
2. ```./getOrionVersionViaKong.sh``` : To get the version of the Orion-LD using KONG as PEP (Policy Enforcement Point) proxy
3. ```./getDataSensors.sh openiot PM_SENSOR``` : To get the last measurement of the pm_sensor-001 (The sensors was created with the setup_demo.sh script)
4. ```./getDataSensorsViaKong.sh openiot PM_SENSOR``` : To get the last measurement of the pm_sensor-001 using KONG as PEP (Policy Enforcement Point) proxy

### Query Mintaka to get access to the temporal NGSI-LD interface 
1. ```./getMintakaInfo.sh``` : To get the version of the Mintaka
2. ```./getMintakaInfoViaKong.sh``` : To get the version of the Mintaka using KONG as PEP (Policy Enforcement Point) proxy
3. ```./getMintakaSensor.sh openiot urn:ngsi-ld:PM_SENSOR:pm_sensor-001``` : To get the latest 5 measurements of the pm_sensor-001 (The sensors was created with the setup_demo.sh script)
4. ```./getMintakaSensorViaKong.sh openiot urn:ngsi-ld:PM_SENSOR:pm_sensor-001``` : To get the 5 latest measurements of the pm_sensor-001 using KONG as PEP (Policy Enforcement Point) proxy

When a program with the word "Token" is run, it requests the token from the local Keycloak server and supplies it with the request to the Kong proxy. See 'getOrionToken.sh', 'getTokenMintaka.sh' are run to request the token from the Keycloak and they save the received token on the 'token.txt' and 'tokenMintaka.txt'.  

## Demo with IoT Agent - MQTT
**IMPORTANT** Enable the corresponding variable in the service.sh file (change the configuration to activate the Docker with IoT MQTT Agent (comment L17 and uncomment L19)) and install the [mosquitto_pub](https://mosquitto.org/download/).

A demo script has been developed. See [demo_data_mqtt](./demo_data_mqtt/) for more details.
run: ```./setup_demo_mqtt.sh```, to create a Energy meter sensor (ID urn:ngsi-ld:PM_SENSOR:pm_sensor-001) and add 10 random measurements.
See [tutorials.IoT-over-MQTT](https://github.com/FIWARE/tutorials.IoT-over-MQTT/tree/NGSI-LD) to familiarize with the use of Orion-LD and IoT JSON Agent.
An instance of energy sensor is created on the Fiware IoT Agent MQTT and the senor data are feed by a POST method (see [demo_data/generate_measurements_energy_meter.sh](demo_data/generate_measurements_energy_meter.sh)) to the corresponding end point.

### Query Orion-LD to get the last values  
You can use the following commands:
1. ```./getOrionVersion.sh``` : To get the version of the Orion-LD
2. ```./getOrionVersionViaKong.sh``` : To get the version of the Orion-LD using KONG as PEP (Policy Enforcement Point) proxy
3. ```./getDataSensors.sh ENERGY_METER``` : To get the last measurement of the pm_sensor-001 (The sensors was created with the setup_demo.sh script)
4. ```./getDataSensorsViaKong.sh ENERGY_METER``` : To get the last measurement of the pm_sensor-001 using KONG as PEP (Policy Enforcement Point) proxy

### Query Mintaka to get access to the temporal NGSI-LD interface 
1. ```./getMintakaInfo.sh``` : To get the version of the Mintaka
2. ```./getMintakaInfoViaKong.sh``` : To get the version of the Mintaka using KONG as PEP (Policy Enforcement Point) proxy
3. ```./getMintakaSensor.sh openiot_mqtt urn:ngsi-ld:ENERGY_METER:energymeter-001``` : To get the latest 5 measurements of the pm_sensor-001 (The sensors was created with the setup_demo.sh script)
4. ```./getMintakaSensorViaKong.sh openiot_mqtt urn:ngsi-ld:ENERGY_METER:energymeter-001``` : To get the 5 latest measurements of the pm_sensor-001 using KONG as PEP (Policy Enforcement Point) proxy

## Keycloak, create new realm
**The following procedure is NOT required to run the demo. The following step NEEDS TO BE PERFORMED when you need to run ANYTHING else except the current demo.**    

Update the following variables **AT THE MINIMUM** into the '.env.secrets' file.
- KEYCLOAK_DB_USER
- KEYCLOAK_DB_PASSWORD
- KEYCLOAK_USER
- KEYCLOAK_PASSWORD

Follow the instructions to create a new Realm on Keycloak. When run for the first time, go to https://localhost:8443 with the following credentials admin:Pa55w0rd (.env-> KEYCLOAK_USER:KEYCLOAK_PASSWORD).

Go to left menu, on the top, click on master then click on "add" and load the file "keycloak/keycloack-fiware-serviceWithMintaka.json" under keycloak folder.
Add a user, Users with the following credentials admin-user:admin-user, Groups: admin, consumer. PLEASE USE custom user credentials for your own installation. 

### Setup orion-pep client
- Go to Clients->orion-pep->Credentials-> Regenerate. Copy/paste key to client_secret in the 'getOrionToken.sh' file. Also update the username, password with your custom credential created before
- Go to kong-config/kong.yaml: search for "keycloakclientsecret" in the service "orion-keycloak" and paste the key.

### Setup mintaka-pep client
- Go to Clients->mintaka-pep->Credentials-> Regenerate. Copy/paste key to client_secret in the 'getTokenMintaka.sh' file. Also update the username, password with your custom credential created before
- Go to kong-config/kong.yaml: search for "keycloakclientsecret" in the service "mintaka-keycloak" and paste the key 

**Then restart docker!**


Now rerun all the commands containing keyword 'Token' to verify the configuration is correct. If the following error appears when you run any of the commands 'parse error: Invalid numeric literal at line 1, column 9', open the file of the command and remove from the end the '|jq', rerun the command to get the actual error. jq is used for the formatting of the return json from Orion-LD and Mintaka.



