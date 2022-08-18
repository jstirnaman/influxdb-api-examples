INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

# InfluxDB default is 100.

function get_tasks() {
  TASK="/${1}"

  if [ -z $1]; then
    TASK=""
  fi

  curl -v --request GET \
    "${INFLUX_URL}/api/v2/tasks${TASK}?limit=${LIMIT}" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}

function get_tasks_after() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?after=${1}" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}

function get_tasks_by_name() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?name=task1" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}

function get_tasks_by_status() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?status=${1}" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}
# get_tasks_by_status inactive
# get_tasks_by_status active

# https://docs.influxdata.com/influxdb/v2.3/reference/release-notes/influxdb/#task-metadata
function get_tasks_as() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?limit=100" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq '. | .tasks'
}
# get_tasks_as basic
# get_tasks_as system

flux="from(bucket: params.bucket)
                 |> range(start: duration(v: params.rangeStart))
                 |> filter(fn: (r) => r._field == params.filterField)
                 |> group(columns: [params.groupColumn])"

function create_task_cloud() {
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/tasks" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_TOKEN}" \
    --data-binary @- << EOF | jq .
    {
    "every": "60m",
    "description": "IoT Center environment running average.",
    "name": "30-day-avg",
    "scriptID": "09b2136232083000",
    "scriptParameters":
      {
        "rangeStart": "task.every",
        "bucket": "air_sensor",
        "filterField": "temperature",
        "groupColumn": "_time"
      }
    }
EOF
}

function create_script_task_cloud() {
  SCRIPT_ID=$(
  curl "${INFLUX_URL}/api/v2/scripts" \
    --header "Authorization: Token ${INFLUX_TOKEN}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data-binary @- << EOF | jq -r '.id'
    {
      "name": "filter-and-group21",
      "description": "Returns filtered and grouped points from a bucket.",
      "script": "from(bucket: params.bucket)\
                 |> range(start: duration(v: params.rangeStart))\
                 |> filter(fn: (r) => r._field == params.filterField)\
                 |> group(columns: [params.groupColumn])",
       "language": "flux"
    }
EOF
)

echo $SCRIPT_ID

curl -v $INFLUX_URL/api/v2/tasks \
--header "Content-type: application/json" \
--header "Authorization: Token $INFLUX_TOKEN" \
--data @- << EOF
  {
  "name": "avg task",
  "every": "60m",
  "scriptID": "${SCRIPT_ID}",
  "scriptParameters":
    {
      "rangeStart": "-30d",
      "bucket": "air_sensor",
      "filterField": "temperature",
      "groupColumn": "_time"
    }
  }
EOF
}

function update_task() {
  curl -v --request PATCH \
    "${INFLUX_URL}/api/v2/tasks/${1}" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_TOKEN}" \
    --data-binary @- << EOF | jq .
      {
        "description": "IoT Center 30d environment average.",
        "flux":  "option task = {name: \"iot-center-task-3\", every: 60s} \
                  from(bucket: \"air_sensor\") \
                      |> range(start: 1h) \
                      |> filter(fn: (r) => r._field == \"temperature\") \
                      |> group(columns: [\"_time\"])",
        "status": "active"
      }
EOF
}

function delete_task() {
  curl -v --request DELETE \
	"${INFLUX_URL}/api/v2/tasks/${1}" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}

function get_task_runs() {
  query=$2

  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/runs${query}" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_TOKEN}"
}

function get_task_run() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}

function get_task_run_logs() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}/logs" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}

function get_task_logs() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/logs" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}

function run_task() {
  curl -v --request POST \
	  "${INFLUX_URL}/api/v2/tasks/${1}/runs" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_TOKEN}"
}

# Cancel a task run.
function cancel_run() {
    curl -v --request DELETE \
	  "${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_TOKEN}"
}

function retry_run() {
    curl -v --request POST \
	  "${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}/retry" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_TOKEN}"
}