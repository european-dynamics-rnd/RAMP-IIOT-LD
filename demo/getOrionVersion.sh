#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)

echo -e 'Orion-lD needs to run on localhost'

curl -s -X GET  'http://localhost:'"${ORION_LD_PORT}"'/version' |jq 
# curl -s -X GET  'http://localhost:'"${ORION_LD_PORT}"'/admin/metrics' |jq 
