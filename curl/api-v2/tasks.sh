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
    --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_tasks_after() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?after=${1}" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_tasks_by_name() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?name=task1" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_tasks_by_status() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?status=${1}" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}
# get_tasks_by_status inactive
# get_tasks_by_status active

# https://docs.influxdata.com/influxdb/v2.3/reference/release-notes/influxdb/#task-metadata
function get_tasks_as() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks?limit=100" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" | jq '. | .tasks'
}
# get_tasks_as basic
# get_tasks_as system

flux="option task = {name: \"iot-center-task-3\", every: 60s} \
                  from(bucket: \"params.bucket\") \
                      |> range(start: 1h) \
                      |> filter(fn: (r) => r._field == \"temperature\") \
                      |> group(columns: [\"_time\"])"

function create_task() {
  curl -v --request POST \
    "$INFLUX_URL/api/v2/tasks" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF
    {
      "orgID": "${INFLUX_ORG_ID}",
      "description": "IoT Center environment running average.",
      "status": "active",
      "flux": "option task = {name: \"iot-center-task-3\", every: 1h} \
                  from(bucket: \"params.bucket\") \
                      |> range(start: 1h) \
                      |> filter(fn: (r) => r._field == \"temperature\") \
                      |> group(columns: [\"_time\"])"
    }
EOF
}

function create_task_cloud() {
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/tasks" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF
    {
    "every": "60m",
    "description": "IoT Center environment running average.",
    "name": "30-day-avg",
    "scriptID": "${SCRIPT_ID}",
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

function create_task_cloud_requires_script() {
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/tasks" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF
    {
    "every": "60m",
    "description": "IoT Center environment running average.",
    "name": "30-day-avg",
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
  # First, create an invokable script.
  SCRIPT_ID=$(
  curl "${INFLUX_URL}/api/v2/scripts" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
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

# Create a new task that runs the script.
curl -v $INFLUX_URL/api/v2/tasks \
--header "Content-type: application/json" \
--header "Authorization: Token $INFLUX_API_TOKEN" \
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
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF | jq .
      { "orgID": "${INFLUX_ORG_ID}",
        "description": "IoT Center 30d environment average.",
        "scriptID": "${SCRIPT_ID}",
        "status": "active"
      }
EOF
      # { "orgID": "${INFLUX_ORG_ID}",
      #   "description": "IoT Center 30d environment average.",
      #   "flux":  "option task = {name: \"iot-center-task-3\", every: 60s} \
      #             from(bucket: \"air_sensor\") \
      #                 |> range(start: 1h) \
      #                 |> filter(fn: (r) => r._field == \"temperature\") \
      #                 |> group(columns: [\"_time\"])",
      #   "status": "active"
      # }
}

function delete_task() {
  curl -v --request DELETE \
	"${INFLUX_URL}/api/v2/tasks/${1}" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_task_runs() {
  query=$2

  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/runs${query}" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_task_run() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_task_run_logs() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}/logs" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_task_logs() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/tasks/${1}/logs" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function run_task() {
  curl -v --request POST \
	  "${INFLUX_URL}/api/v2/tasks/${1}/runs" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function manual_run_requires_an_active_task() {
  TASK_ID=`create_task | jq -r .id`

  curl -v --request PATCH \
    "${INFLUX_URL}/api/v2/tasks/${TASK_ID}" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF | jq .
      { "orgID": "${INFLUX_ORG_ID}",
        "description": "IoT Center 30d environment average.",
        "status": "inactive"
      }
EOF

  run_task $TASK_ID | jq .
}

# Cancel a task run.
function cancel_run() {
    curl -v --request DELETE \
	  "${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function retry_run() {
    curl -v --request POST \
	  "${INFLUX_URL}/api/v2/tasks/${1}/runs/${2}/retry" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function label_task() {
    TASK_ID=`create_task | jq -r '.id'`
    label=`curl -v --request POST $INFLUX_URL/api/v2/labels \
	            --header "Authorization: Token ${INFLUX_API_TOKEN}" \
              --data-binary @- << EOF
                {
                  "orgID": "${INFLUX_ORG_ID}",
                  "name": "collection 2"
                }
EOF
`
    LABEL_ID=`echo "$label" | jq -r '.label.id'`
    curl -v --request POST \
	  "${INFLUX_URL}/api/v2/tasks/$TASK_ID/labels" \
      --header "Content-type: application/json" \
	    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
      --data-binary @- << EOF
        {}
EOF
}

function delete_task_label() {
    TASK_ID=`create_task | jq -r '.id'`
    labels=`curl $INFLUX_URL/api/v2/tasks/$TASK_ID/labels \
	            --header "Authorization: Token ${INFLUX_API_TOKEN}" \
            | jq -r .labels`
    LABEL_ID=echo "$labels" | jq -r 'last(.[.id])'
    curl -v --request DELETE \
	  "${INFLUX_URL}/api/v2/tasks/$TASK_ID/labels/$LABEL_ID" \
      --header "Content-type: application/json" \
	    --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_task_owners_and_members() {
  TASK_ID=`get_tasks | jq -r '.tasks[0] | .id'`

  curl -v $INFLUX_URL/api/v2/tasks/$TASK_ID/owners \
	            --header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .

  curl -v $INFLUX_URL/api/v2/tasks/$TASK_ID/members \
	            --header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .
}

## Create a new token with task read-write perms.
# INFLUX_TOKEN=`curl -v $INFLUX_URL/api/v2/authorizations \
#           --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
#           --data-binary @- << EOF | jq -r '.token'
#             {
#               "orgID": "${INFLUX_ORG_ID}",
#               "description": "read-write-tasks",
#               "permissions": [
#                 {
#                   "action": "read",
#                   "resource": {
#                     "type": "tasks"
#                   }
#                 },
#                 {
#                   "action": "write",
#                   "resource": {
#                     "type": "tasks"
#                   }
#                 }
#               ]
#             }
# EOF
# `

# label_task
#create_task
#update_task $TASK_ID
#delete_label
# get_task_owners_and_members
# get_tasks

manual_run_requires_an_active_task