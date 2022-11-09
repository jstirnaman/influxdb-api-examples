#!/bin/bash -e

timestamp=`date +%s`;

function create_org() {
curl -v --request POST "${INFLUX_URL}/api/v2/orgs" \
  --header "Content-Type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" \
  --data-binary @- << EOF
    {
        "name": "iot-center-org-${timestamp}",
        "description": "My IoT Center Org"
    }
EOF
}

function delete_org() {
  curl -v --request DELETE \
	"${INFLUX_URL}/api/v2/orgs?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .
}

function get_org() {
params=$1
curl -v --request GET \
	"${INFLUX_URL}/api/v2/orgs$params" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .
}
#get_org
#get_org $INFLUX_ORG_ID


create_org
get_org


