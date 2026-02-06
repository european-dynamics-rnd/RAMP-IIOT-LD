#!/usr/bin/env python3
"""
Configure Uptime Kuma monitors for all RAMP-IoT services.

Requires: pip install uptime-kuma-api
"""

import argparse
import sys

from uptime_kuma_api import UptimeKumaApi, MonitorType
from uptime_kuma_api.exceptions import Timeout


def parse_args():
    parser = argparse.ArgumentParser(description="Setup Uptime Kuma monitors")
    parser.add_argument("--url", required=True, help="Uptime Kuma URL")
    parser.add_argument("--username", required=True, help="Admin username")
    parser.add_argument("--password", required=True, help="Admin password")
    parser.add_argument("--orion-port", default="1026")
    parser.add_argument("--mongo-port", default="27017")
    parser.add_argument("--mintaka-port", default="8086")
    parser.add_argument("--timescale-port", default="5432")
    parser.add_argument("--keycloak-port", default="8080")
    parser.add_argument("--kong-port", default="443")
    parser.add_argument("--iota-mqtt-north-port", default="4042")
    parser.add_argument("--mqtt-port", default="1883")
    parser.add_argument("--prometheus-port", default="9090")
    parser.add_argument("--alertmanager-port", default="9093")
    return parser.parse_args()


# All monitors to configure: (name, type, config_dict)
def build_monitors(args):
    """Build the list of monitors matching all RAMP-IoT services."""
    return [
        # --- Core NGSI-LD ---
        {
            "name": "Orion-LD Context Broker",
            "type": MonitorType.HTTP,
            "url": f"http://ramp_iiot-orion:{args.orion_port}/version",
            "interval": 60,
            "maxretries": 3,
            "description": "NGSI-LD Context Broker – Orion-LD",
        },
        {
            "name": "Mintaka Temporal API",
            "type": MonitorType.HTTP,
            "url": f"http://ramp_iiot-mintaka:{args.mintaka_port}/info",
            "interval": 60,
            "maxretries": 3,
            "description": "Temporal API for NGSI-LD historical data",
        },
        # --- Databases ---
        {
            "name": "MongoDB",
            "type": MonitorType.PORT,
            "hostname": "ramp_iiot-mongo-db",
            "port": int(args.mongo_port),
            "interval": 60,
            "maxretries": 3,
            "description": "MongoDB database for Orion-LD",
        },
        {
            "name": "TimescaleDB",
            "type": MonitorType.PORT,
            "hostname": "ramp_iiot-timescale-db",
            "port": int(args.timescale_port),
            "interval": 60,
            "maxretries": 3,
            "description": "TimescaleDB for temporal data (Mintaka/TRoE)",
        },
        # --- Security ---
        {
            "name": "Keycloak IAM",
            "type": MonitorType.HTTP,
            "url": f"http://keycloak:{args.keycloak_port}/health/ready",
            "interval": 60,
            "maxretries": 3,
            "description": "Keycloak Identity & Access Management",
        },
        {
            "name": "Kong API Gateway",
            "type": MonitorType.PORT,
            "hostname": "kong",
            "port": int(args.kong_port),
            "interval": 60,
            "maxretries": 3,
            "description": "Kong API Gateway (PEP Proxy)",
        },
        # --- IoT Agents ---
        {
            "name": "IoT Agent MQTT",
            "type": MonitorType.HTTP,
            "url": f"http://iot-agent-mqtt:{args.iota_mqtt_north_port}/iot/about",
            "interval": 60,
            "maxretries": 3,
            "description": "FIWARE IoT Agent for JSON over MQTT",
        },
        {
            "name": "Mosquitto MQTT Broker",
            "type": MonitorType.PORT,
            "hostname": "mosquitto",
            "port": int(args.mqtt_port),
            "interval": 60,
            "maxretries": 3,
            "description": "Eclipse Mosquitto MQTT message broker",
        },
        # --- Monitoring ---
        {
            "name": "Prometheus",
            "type": MonitorType.HTTP,
            "url": f"http://prometheus:{args.prometheus_port}/-/healthy",
            "interval": 60,
            "maxretries": 3,
            "description": "Prometheus metrics collection",
        },
        {
            "name": "Alertmanager",
            "type": MonitorType.HTTP,
            "url": f"http://prometheus-alertmanager:{args.alertmanager_port}/-/healthy",
            "interval": 60,
            "maxretries": 3,
            "description": "Prometheus Alertmanager",
        },
        # --- Supporting ---
        {
            "name": "LD Context Server",
            "type": MonitorType.HTTP,
            "url": "http://ramp_iiot-ld-context/merge_data_model.jsonld",
            "interval": 120,
            "maxretries": 3,
            "description": "Apache HTTPD serving JSON-LD @context files",
        },
    ]


def main():
    args = parse_args()
    api = UptimeKumaApi(args.url)

    # --- Initial setup or login ---
    fresh_instance = False
    try:
        # First-time setup: create admin account
        api.setup(args.username, args.password)
        print(f"✔ Created admin user '{args.username}'")
        fresh_instance = True
        # Reconnect after setup so the session is fully authenticated
        api.disconnect()
        api = UptimeKumaApi(args.url)
        api.login(args.username, args.password)
    except Exception:
        # Already set up – just login
        api.login(args.username, args.password)
        print(f"✔ Logged in as '{args.username}'")

    # --- Fetch existing monitors to avoid duplicates ---
    existing = set()
    try:
        existing = {m["name"] for m in api.get_monitors()}
    except Timeout:
        # Fresh instance has no monitors; the event never fires – that's OK
        if not fresh_instance:
            raise
    print(f"  Existing monitors: {len(existing)}")

    # --- Create monitors ---
    monitors = build_monitors(args)
    created = 0
    skipped = 0

    for mon in monitors:
        name = mon["name"]
        if name in existing:
            print(f"  ⏭  '{name}' already exists – skipping")
            skipped += 1
            continue

        try:
            api.add_monitor(**mon)
            print(f"  ✔ Added monitor: {name}")
            created += 1
        except Exception as e:
            print(f"  ✖ Failed to add '{name}': {e}", file=sys.stderr)

    print(f"\nDone: {created} created, {skipped} skipped (already existed)")
    api.disconnect()


if __name__ == "__main__":
    main()
