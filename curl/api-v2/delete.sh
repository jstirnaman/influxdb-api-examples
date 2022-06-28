export INFLUX_BUCKET=airSensors
# export INFLUX_BUCKET_ID=453438dd3110164d
# export INFLUX_ORG=jstirnamaninflux
# export INFLUX_ORG_ID=12ecfe5b8de761f8
# export FAKE_ORG_ID=12ecfe5b8de761f9
# export FAKE_BUCKET_ID=453438dd3110164z
# export FAKE_BUCKET=airJordans

INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

function get_bucket() {
curl -v \
	"${INFLUX_URL}/api/v2/buckets/$1?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
get_bucket
#get_bucket $INFLUX_BUCKET_ID

function delete() {
echo $timestamp;
curl -v -XPOST \
	"${INFLUX_URL}/api/v2/delete?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=s" \
	--header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
    --header "Accept: application/json" \
    --data-binary @- << EOF | jq .
        {
			"start": "2022-04-27T14:59:19.000Z",
			"stop": "2022-04-27T14:59:19.000Z",
			"predicate": "sensor_id=TLM0202"
		}
EOF
}
delete
