#!/bin/bash -e

timestamp=`date +%s`;

function delete_dashboard() {
  curl -v --request DELETE \
	"$INFLUX_URL/api/v2/dashboards?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .
}

function get_dashboards() {
  params=$1

  curl -v "$INFLUX_URL/api/v2/dashboards${params}" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function create_dashboard() {
curl -v --request POST \
	"${INFLUX_URL}/api/v2/dashboards" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" \
  --data '{
    "orgID": "'"${INFLUX_ORG_ID}"'",
    "name": "'"iot-center-${timestamp}"'",
    "description": "My IoT Center Dashboard"
  }'
}

# create_dashboard | jq '.'
get_dashboards "/"
#get_dashboards "?limit=3&orgID=${INFLUX_ORG_ID}" | jq '.dashboards[] | [.id, .type, .orgID]'
#get_dashboards "?limit=3" | jq '.dashboards[] | [.id, .type, .orgID]'
#get_dashboards "?orgID=${INFLUX_ORG_ID}" | jq '.dashboards[] | [.id, .type, .orgID]'
#get_dashboards "?limit=1&offset=3" | jq '.dashboards[] | [.id, .type, .orgID]'
