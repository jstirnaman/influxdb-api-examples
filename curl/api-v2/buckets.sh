#!/bin/bash -e

INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

function delete_bucket() {
  curl -v --request DELETE \
	"${INFLUX_URL}/api/v2/buckets?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}

function get_bucket() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/buckets/$1?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
get_bucket
#get_bucket $INFLUX_BUCKET_ID

function create_bucket() {
curl -v --request POST \
	"${INFLUX_URL}/api/v2/buckets" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}" \
  --data '{
    "orgID": "'"${INFLUX_ORG_ID}"'",
    "name": "iot-center",
    "description": "My IoT Center Bucket",
    "rp": "string",
    "retentionRules": [
      {
        "type": "expire",
        "everySeconds": 86400,
        "shardGroupDurationSeconds": 0
      }
    ],
    "schemaType": "implicit"
  }'
}