#!/bin/bash -e

timestamp=`date +%s`;

function delete_bucket() {
  curl -v --request DELETE \
	"$INFLUX_URL/api/v2/buckets?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}

function get_buckets() {
  params=$1

  curl -v "$INFLUX_URL/api/v2/buckets${params}" \
    --header "Authorization: Token ${INFLUX_TOKEN}"
}

function create_bucket() {
curl -v --request POST \
	"${INFLUX_URL}/api/v2/buckets" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}" \
  --data '{
    "orgID": "'"${INFLUX_ORG_ID}"'",
    "name": "'"iot-center-${timestamp}"'",
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

# create_bucket | jq '.'
get_buckets "?limit=3&orgID=${INFLUX_ORG_ID}" | jq '.buckets[] | [.id, .type, .orgID]'
get_buckets "?limit=3" | jq '.buckets[] | [.id, .type, .orgID]'
get_buckets "?orgID=${INFLUX_ORG_ID}" | jq '.buckets[] | [.id, .type, .orgID]'
get_buckets "?limit=1&offset=3" | jq '.buckets[] | [.id, .type, .orgID]'