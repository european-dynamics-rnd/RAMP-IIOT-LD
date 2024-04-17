Partners
Open source RAMP IoT LD platform is a complete connectivity solution, that allows you to control devices, gather and visualize data and link customized applications.

But how does it work?

Step 1: Your factory’s machines, workers, robots, sensors etc. send their data to the RAMP IoT LD platform, following the [NGSI-LD](https://www.etsi.org/deliver/etsi_gs/CIM/001_099/009/01.07.01_60/gs_cim009v010701p.pdf) protocol. You can see the available [FIWARE generic enablers](https://github.com/FIWARE/catalogue)

Step 2: The platform receives the data and then can either:

    Send certain commands back the factory entities
    Send the data to RAMP dashboard for visualization
    Store the machines’ data for future use

RAMP IoT LD platform is fully compatible with multiple machine protocols, using FIWARE compatible adapters.

Step 3:  Based on the action that is performed in the previous step:

    Factory entities can receive and execute any received commands
    Data visualizations are generated on the RAMP dashboard, in order for you to have a clear view of your factory’s productivity
    Past data can be found, in order to
        identify possible faults or delays and make any necessary adjustments
        compare with current data

RAMP IoT LD Plarform is a FIWARE-based package to be installed on factory premises and is connected with RAMP.
[Download RAMP IoT LD platform](https://github.com/european-dynamics-rnd/RAMP-IOT-LD). In the repository you can find more detailed instruction and varius of examples.

It provides a set of FIWARE Generic Enablers ready to be used as IoT platform.

Here is a list of key components with their interfaces:

- Port 1026 [Orion-LD](https://github.com/FIWARE/context.Orion-LD) Context Broker without PEP (Policy Enforcement Point) Proxy
- Port 8086 [Mintaka](https://github.com/FIWARE/mintaka) as NGSI-LD temporal retrieval API 
- Port 443 PEP Proxy port to Orion-LD and Mintaka (OAuth2 token is required)
- Port 4041 IoT Agent port. This is the port to which sensors should be sending data. FIWARE IoT Agent documentation is recommended read
- Port 8443 Keycloak interface. Keycloak can offer OAuth2 authentication service if other service is not used

If all the above sound like a good idea, let’s start our journey together! 