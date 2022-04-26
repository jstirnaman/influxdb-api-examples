#!/bin/bash -e

#source "./oss.env"
source "./cloud.env"

export INFLUX_BUCKET=air_sensor
export INFLUX_BUCKET_ID=4c49b5a778674148
export INFLUX_DBRP_NAME=air_sensor_db

function query() {
basic=$(echo "${INFLUX_USER_NAME}:${INFLUX_ALL_ACCESS_TOKEN}" | base64)

echo "token auth"
curl -vv --get "${INFLUX_URL}/query" \
  --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
  --data-urlencode "rp=${INFLUX_DBRP_NAME}" \
  --data-urlencode "q=SELECT * FROM airSensors" \
  | jq .

echo "basic auth"
curl -vv --get "${INFLUX_URL}/query" \
  --user "${INFLUX_USER_NAME}":"${INFLUX_ALL_ACCESS_TOKEN}" \
  --data-urlencode "rp=${INFLUX_DBRP_NAME}" \
  --data-urlencode "q=SELECT * FROM airSensors" \
  | jq .
}
query

function dbrps_create() {
  curl --request POST "${INFLUX_URL}/api/v2/dbrps" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
   --header 'Content-type: application/json' \
   --data '{
        "bucketID": "'"$INFLUX_BUCKET_ID"'",
        "database": "'"$INFLUX_DBRP_NAME"'",
        "default": true,
        "orgID": "'"$INFLUX_ORG_ID"'",
        "retention_policy": "autogen"
      }'
}
# dbrps_create
