#!/bin/bash -e

INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

function get_bucket() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/buckets/$1?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq '.[] | arrays | .[] | select(.name | contains("monitoring")) | .id'
}
get_bucket 

function query() {
curl -v --request POST \
	"${INFLUX_URL}/api/v2/query?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" \
	--header 'Accept: application/csv' \
	--header 'Content-type: application/vnd.flux' \
	--data 'from(bucket: "_monitoring")
                |> range(start: -360d)'
}

query

