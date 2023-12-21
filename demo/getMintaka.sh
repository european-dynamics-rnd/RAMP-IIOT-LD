#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)


curl -s -X GET  'http://localhost:'"${MINTAKA_PORT}"'/info' |jq 

