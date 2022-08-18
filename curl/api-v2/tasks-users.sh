INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

# InfluxDB default is 100.

function get_tasks_owners() {
  TASK="/${1}"

  if [ -z $1]; then
    $TASK=""
  fi

  query=$2

  curl -v --request GET \
    "${INFLUX_URL}/api/v2/tasks${TASK}/owners$2" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}

function add_task_owners() {
  TASK_ID=$1
  USER_ID=$2

  curl -v --request POST \
    "${INFLUX_URL}/api/v2/tasks/$TASK_ID/owners" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
    --data-binary @- << EOF
      {
        "id": "$USER_ID"
      }
EOF
}

#### Helpers

function list_users() {
  params=$1

  curl -v --request GET \
    "${INFLUX_URL}/api/v2/users${params}" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header "Content-type: application/json"
}

function get_tasks() {
  params=$1

  curl -v --request GET \
    "${INFLUX_URL}/api/v2/tasks${params}" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}

taskid=`get_tasks | jq -r '.tasks[0].id'`
userid=`list_users | jq -r '.users[0].id'`

add_task_owners $taskid $userid

# get_tasks_owners $taskid
