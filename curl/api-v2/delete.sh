source "./data/v2-fake-data.sh"

export INFLUX_BUCKET=air_sensor

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
curl -v \
	"${INFLUX_URL}/api/v2/delete?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=s" \
	--header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
        --header "Accept: application/json"