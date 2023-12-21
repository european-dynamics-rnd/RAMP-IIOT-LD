#!/bin/bash
set -e
export $(cat ../.env | grep "#" -v)


if [ "$HOST" == "localhost" ]; then
  INSECURE=' --insecure '
else
  INSECURE=''
fi

if [ "$1" = "SSO" ]; then
  echo "Redicecting to ramp.eu for login"
  python3 getToken_oauth2.py 
else
  ./getToken.sh
fi
token=$(cat "token.txt")



KONG_URL='https://'"${HOST}"':'"${KONG_PORT}"'/keycloak-orion'
# echo $KONG_URL
curl -s $INSECURE ''"${KONG_URL}"'/version' \
 --header 'Authorization: Bearer '"${token}"' ' | jq