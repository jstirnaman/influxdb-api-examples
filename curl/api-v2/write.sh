INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

timestamp=`date +%s`;

function write() {
curl -v \
        "${INFLUX_URL}/api/v2/write?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=s" \
        --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
        --header "Accept: application/json" \
        --data-binary @- <<EOF | jq .
                homeSensor,room=Living\ Room temp=21.5,hum=35.9,co=0i $timestamp
                homeSensor,room=Kitchen temp=22.8,hum=35.9,co=0i $timestamp
                homeSensor,room=Bedroom temp=20.5,hum=34.9,co=0i $timestamp
EOF

# --data-binary @- <<'EOF' | jq .
# # Literal backslash at start of string field value.
# # Escaped backslash at end of string field value.
# airSensor,sensor_id=TLM\=0201 desc="\=My data==\\"
# airSensors,sensor_id=TLM0201 temperature=75.30007505999716,humidity=35.651929918691714,co=0.5141876544505826
# airSensors,sensor_id=TLM0202 temperature=76.30007505999716,humidity=36.651929918691714,co=0.5241876544505826
# # Measurement name with literal backslashes.
# # Escaped = in tag value.
# # Escaped \ and escaped " in string field value.
# air\\\\\Sensor,sensor_id=TLM\=0201 desc="\\\"==My data\==\\"
# EOF


# --header "Content-type: text/plain; charset=utf-8" \
 #air\\\\\Sensor,sensor_id=TLM\=0201 desc="\\==My data\=="
  # Measurement name with literal backslashes.
  # Escaped = in tag value, escaped \ and escaped " in string field value.
  # air\\\\\Sensor,sensor_id=TLM\=0201 desc="\\\"==My data\==\\"
#	--data "airSensors,sensor_id=TLM0201 temperature=73.97,humidity=35.23,co=0.48 $timestamp
#	        airSensor's,sensor_id=TLM0201 temperature=73.97,humidity=35.23,co=0.48 $timestamp
#                joe'smeasurement,pat'sTag=tag1 fieldKey=100
#		air\\\Sensor,sensor_id=TLM0201 temp=70.0,humidity=0.5,desc=""" \
#        | jq .
#  airSensors,sensor_id=TLM0201 temperature=\"75.30007505999716\",humidity=35.651929918691714,co=0.5141876544505826 $timestamp
#  airSensors,sensor_id=TLM0202 temperature=\"75.30007505999716\",humidity=35.651929918691714,co=0.5141876544505826 $timestamp" \
	#--data "air_sensor,service=S1,sensor=L1 temperature=90.5,humidity=70.0 $timestamp
        #        air_sensor,service=S1,sensor=L2 temperature=90.5,humidity=70.0 $timestamp" \
}

function write_compressed() {
fake_points

 curl -vv --request POST \
 "${INFLUX_URL}/api/v2/write?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=s" \
   --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
   --header "Content-Encoding: gzip" \
   --header "Content-Type: text/plain; charset=utf-8" \
   --header "Accept: application/json" \
   --data-binary @air-sensors.gzip
}

  # --data-binary @"../../data/air-sensor-data.lp" \
 # -D ~/log/write-headers.cloud \
# >> ~/log/write.cloud
 # --data @"/Users/jasonstirnaman/github/air-sensor-data-5M.lp"
 # -D ~/log/write-headers.out \
 # >> write.out

 #  --data-raw "
 #      mem host=host1,used_percent=25.434535 1630081733773329000
 #      ,host=host2,used_percent=25.434535 1630081733773329000
 #      " \

 # --data @"../../data/air-sensor-data-5M.lp"

function write_to_bucket_schema() {
my_explicit='my_explicit'

cat <<EOF > air-sensor.lp
  air_sensor,service=S1,sensor=L1 temperature=90.5,humidity=70.0 $timestamp
  air_sensor,service=S1,sensor=L1 temperature="90.5",humidity=70.0 $timestamp
EOF

curl -vv --request POST \
	"${INFLUX_URL}/api/v2/write?org=${INFLUX_ORG_ID}&bucket=${my_explicit}" \
	--header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
	--header "Content-type: text/plain; charset=utf-8" \
        --header "Accept: application/json" \
	--data-binary @air-sensor.lp \
        | jq .
}

# Generate and write from a data file a number of times.
function generate_and_write() {
for run in {1..100}; do (ruby ~/Documents/GitHub/influxdb2-sample-data/air-sensor-data/air-sensor-data.rb > ~/Documents/GitHub/air-sensor-data.lp; sh ~/Documents/GitHub/docs-v2/shared/text/api/v2.0/write.sh) done
}

generate_and_write
# write
