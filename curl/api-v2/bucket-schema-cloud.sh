#!/bin/bash -e

INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

##
# Bucket schema
##

function get_bucket_schema() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/buckets/$1/schema/measurements/?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}

#get_bucket_schema a7d5558b880a93da 

function create_bucket_schema() {
curl -v --request POST \
	"${INFLUX_URL}/api/v2/buckets/$1/schema/measurements/?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" \
        --header "Content-type: application/json" \
        --data '{
	"name": "airSensors",
	"columns": [
          {"name": "time", "type": "timestamp"},
          {"name": "sensorId", "type": "tag"},
          {"name": "temperature", "type": "field"},
          {"name": "humidity", "type": "field", "dataType": "float"},
          {"name": "co", "type": "field", "dataType": "float"}
	  ]
        }' | jq .
}
create_bucket_schema a7d5558b880a93da 
#get_bucket_schema a7d5558b880a93da 

function write() {
# my_explicit='a7d5558b880a93da'
my_explicit='my_explicit'

#cat <<EOF > air-sensor.lp
#  air_sensor,service=S1,sensor=L1 temperature=90.5,humidity=70.0 $timestamp
#  air_sensor,service=S1,sensor=L1 temperature="90.5",humidity=70.0 $timestamp
#EOF
cat <<EOF > air-sensor.lp
  airSensors,sensorId=L1 temperature=90.5,humidity=70.0,co=0.2 $timestamp
  airSensors,sensorId=L1 temperature="90.5",humidity=70.0,co=0.2 $timestamp
EOF

curl -vv --request POST \
	"${INFLUX_URL}/api/v2/write?org=${INFLUX_ORG_ID}&bucket=${my_explicit}" \
	--header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
	--header "Content-type: text/plain; charset=utf-8" \
        --header "Accept: application/json" \
	--data-binary @air-sensor.lp \
        | jq .
}

write

# Generate and write from a data file a number of times.
function generate_and_write() {
for run in {1..100}; do (ruby influxdb2-sample-data/air-sensor-data/air-sensor-data.rb > ~/github/air-sensor-data.lp; sh ~/github/docs-v2/shared/text/api/v2.0/write.sh) done
}


