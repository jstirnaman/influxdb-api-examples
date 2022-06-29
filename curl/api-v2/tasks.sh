INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

function delete_task() {
  curl -v --request DELETE \
	"${INFLUX_URL}/api/v2/tasks?orgID=${INFLUX_ORG_ID}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}

function get_tasks() {
  TASK="/${1}"

  if [ -z $1]; then
    TASK=""
  fi
  curl -v --request GET \
    "${INFLUX_URL}/api/v2/tasks${TASK}" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" | jq .
}
# get_tasks
# get_tasks 0996e5ae67f78000

function get_tasks_after() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?after=${1}" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
# get_tasks_after 09956cbb6d378000

function get_tasks_by_name() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?name=task1" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
# get_tasks_by_name

function get_tasks_by_status() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?status=${1}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
get_tasks_by_status inactive
# get_tasks_by_status active

# https://docs.influxdata.com/influxdb/v2.3/reference/release-notes/influxdb/#task-metadata
function get_tasks_as() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?type=${1}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
get_tasks_as basic
#get_tasks_as system

function create_task() {
curl -v --request POST \
	"${INFLUX_URL}/api/v2/tasks" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}" \
  --data-binary @- << EOF | jq .
    {
    "orgID": "${INFLUX_ORG_ID}",
    "description": "My IoT Center Task",
    "flux": "option task = {name: \"iot-center-task\", every: 30m}\
             from(bucket: \"iot_center\")\
               |> range(start: -90d)\
               |> filter(fn: (r) => r._measurement == \"environment\")\
               |> aggregateWindow(every: 1h, fn: mean)"
    }
EOF
}
# create_task

function update_task() {
curl -v --request PATCH \
	"${INFLUX_URL}/api/v2/tasks/${1}" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}" \
  --data '{
    "status": "active"
  }' | jq .
}
# update_task 09956e2b48778000