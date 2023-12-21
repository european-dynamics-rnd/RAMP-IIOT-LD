#!/bin/bash
#

#

set -e
export $(cat ../.env | grep "#" -v)

if [ "$HOST" == "localhost" ]; then
  INSECURE=' --insecure '
else
  INSECURE=''
fi

if [ "$1" = "SSO" ]; then
  echo "Redicecting to ramp.eu for login"
  python3 getTokenMintaka_oauth2.py 
else
  ./getTokenMintaka.sh
fi
token=$(cat "tokenMintaka.txt")

KONG_URL='https://'"${HOST}"':'"${KONG_PORT}"'/keycloak-mintaka'

curl -s $INSECURE ''"${KONG_URL}"'/info' \
 --header 'Authorization: Bearer '"${token}"' ' |jq
