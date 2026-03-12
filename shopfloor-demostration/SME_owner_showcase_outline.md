# RAMP Shopfloor Data Integration for Manufacturing SMEs

## 1. Introduction

Small and medium-sized manufacturers often operate production assets from different vendors, different generations, and different automation environments. As a result, valuable machine and process data is frequently locked inside local controllers, field devices, displays, or proprietary software. This creates a barrier to visibility, traceability, process improvement, and digital transformation.

The RAMP shopfloor demonstration shows a practical approach for overcoming this challenge. It illustrates how data from different shopfloor devices and communication technologies can be collected, normalized, and made available through a unified industrial data platform. The purpose of this document is to present these capabilities in a form that is relevant to manufacturing SME owners and decision makers, and to clarify what information and documentation should be gathered before starting an integration activity or pilot.


## 2. Connectivity and Integration Capabilities

The current repository and demonstration material show support for several relevant industrial and industrial-adjacent integration paths.

### 2.1 CAN Bus

The demonstration includes CAN-based acquisition for temperature-related measurements and machine-adjacent sensing. CAN is widely used in industrial and embedded environments where robust communication between devices is required.

### 2.2 RS485

The demonstration includes RS485-based communication for transferring measurements from a sensor node to the local computation unit. RS485 remains highly relevant in industrial environments because many machines, instruments, and gateways use it as a physical communication layer.

### 2.3 Modbus

The repository indicates relevance of Modbus in the shopfloor demonstration context, especially in relation to RS485-connected devices. For manufacturing SMEs, this is important because Modbus remains one of the most common ways to expose values from industrial equipment.

### 2.4 MQTT over Wi-Fi

The platform includes MQTT-based ingestion through the FIWARE IoT Agent MQTT and a local Mosquitto broker. This supports wireless or network-connected devices that publish data in a structured message format.

### 2.5 OPC UA

The demonstration material also identifies OPC UA as a relevant machine integration capability. OPC UA is particularly valuable because it is a standardized and widely accepted way to access industrial machine variables, status information, alarms, and process values from modern equipment, PLCs, and gateways.

### 2.6 Internal Sensor Interfaces such as I2C

At node level, the setup also uses internal embedded interfaces such as I2C to acquire measurements from sensors before forwarding them through higher-level communication paths. While this is not usually the manufacturer-facing machine interface, it demonstrates the flexibility of the edge acquisition approach.

### 2.7 Other Interfaces

The same integration approach can be extended to additional protocols and vendor-specific interfaces where adequate documentation is available. This is especially relevant for SMEs operating mixed environments with legacy machines, proprietary controllers, and newer connected assets.

## 3. Demonstration Examples

### 3.1 Scale and Colour Station over RS485

One demonstration node simulates a station that measures the weight of an item and identifies its colour. The node is built around an ESP32-based embedded unit, and the resulting data is transferred over RS485 to the Raspberry Pi-based local system. A software component then converts these measurements into NGSI-LD entities so that they become available through the platform.

From an SME perspective, this kind of use case is relevant for quality checks, material verification, packaging workflows, and station-level traceability.

### 3.2 Environmental Monitoring over Wi-Fi and MQTT

Another demonstration node reads environmental measurements such as temperature, humidity, and pressure, packages them into JSON, and publishes them through MQTT over Wi-Fi. The data is received by the IoT Agent and made available through the common platform.

This type of scenario is relevant for monitoring workspace conditions, sensitive storage zones, environmental conditions around machines, and process-related ambient parameters.

### 3.3 Temperature Monitoring over CAN Bus

The shopfloor demonstration also includes a node that reads temperature values from Pt100 and thermocouple sensors and sends them through CAN bus to the local platform environment. These measurements are then transformed into a common platform representation and can be accessed both in current and historical form.

This is particularly relevant for machine condition monitoring, thermal process supervision, preventive maintenance, and early detection of deviations.

### 3.4 OPC UA-Based Machine Integration

The repository also highlights OPC UA as an integration option. This is highly relevant for SMEs with PLC-based production assets or machines that already expose data through standardized OPC UA servers. In these cases, integration can be faster and more structured because machine variables, status information, and process values can be accessed through a documented standard rather than a custom reverse-engineered interface.

For the manufacturer, this reduces dependency on proprietary integration approaches and can make it easier to connect multiple machines over time.

## 4. Business Value for SME Manufacturers

The value of the system is not limited to collecting data. Its real value lies in making machine and process information usable in a consistent and scalable way.

Key benefits include:

- improved visibility of shopfloor operations
- reduced manual collection and transcription of machine data
- faster identification of anomalies or production deviations
- better support for maintenance and condition monitoring
- stronger support for quality assurance and traceability
- a common data foundation for dashboards, analytics, digital twins, and external services
- a practical migration path from isolated assets to connected operations

For SME owners, this means the platform can support both immediate operational improvements and longer-term digitalization goals.

## 5. Typical Adoption Approach

For most SMEs, the right approach is not to connect everything at once. A more effective path is to start with a small pilot focused on one process, one line, or one set of critical measurements.

A typical adoption path would be:

1. Select one pilot use case with clear business value.
2. Choose one to three machines, stations, or sensing points.
3. Confirm what communication interfaces are available.
4. Gather the relevant machine, protocol, IT, and security documentation.
5. Connect the selected data points to the platform.
6. Validate the expected outcomes and define the next expansion step.

This incremental approach reduces risk and makes the project easier to manage from both a technical and operational point of view.

## 6. Information Needed from the SME

Before starting an onboarding or pilot activity, the SME should provide a small but useful set of business and operational information. This helps align the technical integration effort with the expected business result.

The most important information includes:

- the production objectives of the pilot
- the machines, stations, or lines that should be prioritized
- the measurements or machine states that matter most
- the operational problems to be addressed, such as downtime, quality deviations, energy use, traceability, or compliance
- the expected success criteria and pilot outcomes

Without this alignment, even technically successful integrations may fail to produce clear business value.

## 7. Documents and Materials to Gather Before Onboarding

Proper integration depends heavily on the availability of correct technical and organizational documentation. This is especially important when connecting existing industrial equipment from different manufacturers.

### 7.1 Machine and Process Documentation

The SME should gather:

- a machine list including manufacturer, model, year, and machine role
- machine manuals and technical datasheets
- documentation for PLCs, controllers, HMIs, and local gateways
- process descriptions for the production stations to be monitored
- any existing documentation showing how operators currently read or use the machine data

### 7.2 Connectivity and Data Documentation

The SME should gather:

- register maps, tag lists, variable lists, or point lists
- protocol details for RS485, Modbus, CAN, MQTT, OPC UA, or other interfaces
- message payload examples, sample exports, screenshots, or HMI views
- data update rates or required sampling frequencies
- engineering units, thresholds, alarm limits, and expected operating ranges

### 7.3 Protocol-Specific Documentation Required from the Manufacturer

For reliable and cost-effective integration, manufacturer documentation is essential. This is particularly true for CAN, RS485, Modbus, OPC UA, and any proprietary vendor protocol. Without vendor documentation, integration becomes slower, more uncertain, and more dependent on trial-and-error.

The following protocol-specific information should be requested from the manufacturer or machine supplier.

#### CAN

Request:

- message identifiers
- payload layout
- byte order and encoding rules
- scaling and conversion rules
- transmission timing and frequency
- diagnostics and error behavior

#### RS485

Request:

- wiring details and connector information
- serial communication settings such as baud rate, parity, stop bits, and frame format
- addressing rules
- frame structure
- identification of any higher-level protocol running over RS485

#### Modbus

Request:

- confirmation of Modbus RTU or Modbus TCP
- slave or unit IDs
- register maps
- supported function codes
- data types and signed or unsigned interpretation
- scaling rules
- recommended polling frequency and limits

#### MQTT

Request:

- broker details
- topic structure
- payload schema
- authentication method
- QoS expectations
- publish triggers and update frequency

#### OPC UA

Request:

- server endpoint URLs
- namespace information
- node IDs
- authentication method
- certificates
- security policy and mode
- variable list to be exposed

#### Other Vendor-Specific Interfaces

Request:

- interface specifications
- available SDKs, manuals, or protocol descriptions
- example messages or sample datasets
- any gateway or converter requirements
- vendor constraints or licensing restrictions

If full documentation is not available, the SME should still try to obtain at minimum sample data, variable names, engineering units, communication settings, and alarm meanings.

### 7.4 IT and Network Documentation

The SME should also gather:

- the relevant part of the factory network topology
- IP addressing constraints and VLAN information
- firewall and port opening requirements
- Wi-Fi availability and coverage where applicable
- rules for remote access, external support, and device onboarding

### 7.5 Security and Compliance Documentation

The following should also be clarified early:

- internal cybersecurity requirements
- user roles and access control needs
- password, certificate, or identity management policies
- data retention expectations
- compliance or audit constraints related to production data
- internal approval steps for connecting edge devices or software components

### 7.6 Operational and Project Information

Finally, the project team should have:

- a clear pilot scope
- an agreed timeline
- success criteria and KPIs
- contact persons from production, maintenance, IT, and management
- known installation constraints or maintenance windows
- visibility on machine downtime limitations or access restrictions

## 8. Recommended Next Steps

Based on the demonstrated capabilities, the recommended next step for an SME is to define a focused pilot that combines clear business relevance with manageable integration complexity.

The practical next actions are:

1. Select one use case with measurable value.
2. Choose one to three machines, stations, or sensing points.
3. Confirm whether the assets expose CAN, RS485, Modbus, MQTT, OPC UA, or another interface.
4. Gather the technical and organizational documents listed in this document.
5. Define the measurements, machine states, or events to be integrated.
6. Confirm security, network, and access constraints.
7. Prepare a short pilot implementation plan.

## 9. Conclusion

The RAMP shopfloor demonstration shows that manufacturing SMEs can integrate data from heterogeneous machines and devices without requiring a full replacement of their existing equipment landscape. By supporting multiple communication approaches, including CAN, RS485, Modbus, MQTT, and OPC UA, the platform provides a practical path toward better visibility, improved traceability, and more effective use of machine data.

The main condition for a smooth and efficient integration is preparation. When the SME gathers the right machine, protocol, IT, and security documentation in advance, the onboarding effort becomes faster, less risky, and easier to align with business priorities. This is why the technical information requested from machine manufacturers and internal teams should be treated as a critical project input rather than an administrative detail.