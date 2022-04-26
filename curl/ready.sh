#!/bin/bash -e

function ready() {
curl -v --request GET \
	"${INFLUX_URL}/ready" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}
ready