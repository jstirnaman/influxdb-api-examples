#!/bin/bash -e

INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

timestamp=`date +%s`;

function ping() {
curl -v --request GET \
	"${INFLUX_URL}/ping" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}
ping

function routes() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}
routes


