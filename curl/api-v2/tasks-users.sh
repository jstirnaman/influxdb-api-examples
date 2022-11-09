INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

# InfluxDB default is 100.

function get_task_owners() {
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

function add_task_owner() {
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

  curl -v "${INFLUX_URL}/api/v2/users${params}" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}

function get_tasks() {
  params=$1

  curl -v --request GET \
    "${INFLUX_URL}/api/v2/tasks${params}" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}

function add_member() {
  userid=$1
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/orgs/$INFLUX_ORG_ID/members" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header "Content-type: application/json" \
    --data-binary @- << EOF
        { "id": "$userid" }
EOF
}

function get_org_owners() {
  curl -v --request GET \
    "${INFLUX_URL}/api/v2/orgs/${INFLUX_ORG_ID}/owners" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}"
}

function add_org_owner() {
  userid=$1
  curl -v "${INFLUX_URL}/api/v2/orgs/${INFLUX_ORG_ID}/owners" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --data-binary @- << EOF
        { "id": "$userid" }
EOF
}

function delete_org_owner() {
  userid=$1
  curl -v --request DELETE "${INFLUX_URL}/api/v2/orgs/${INFLUX_ORG_ID}/owners/$userid" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}

function get_legacy_auths() {
  # Use Op token to list _all_ auths, otherwise only returns auths created by the
  # token you pass.

  query=$1
  curl -v "${INFLUX_URL}/private/legacy/authorizations$query" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}

function test_task_owner_basic_auth() {
  # 1. Get a task.
  taskid=`get_tasks | jq -r '.tasks[0].id'`

  # 2. Find a user by name and return user ID.
  users=`list_users`
  user=`echo "$users" | jq --arg username $INFLUX_USER_NAME '.users[] | select(.name == $username)'`
  userid=`echo "$user" | jq -r '.id'`

  # 2. Check for task owner.
  owners=`get_task_owners $taskid`
  ownerid=`echo "$owners" | jq -r --arg userid $userid '.users[] | select(.id == $userid) | .id'`

  # 2. Is user a member of the org? There's no method for this, so dig into the list.
  members=`curl "${INFLUX_URL}/api/v2/orgs/$INFLUX_ORG_ID/members" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"`

  member=`echo "$members" | jq --arg id $ownerid '.users[] | select(.id == $id)'`

  if [ -z "$member" ]; then
    # User isn't a member.
    # Add the user to members.
    member=`add_member $ownerid`
  fi

  memberid=`echo "$member" | jq -r '.id'`
  echo "#### Member ID ${memberid}"

  legacy_auths=`get_legacy_auths "?userID=$memberid"`
  legacy_auth_token=`echo "$legacy_auths" | jq -r '.authorizations[0] | .token'`

  # 4. Use basic auth to get the task.
  curl -v "${INFLUX_URL}/api/v2/tasks/$taskid" \
             --header "Authorization: Basic $legacy_auth_token:$INFLUX_USER_PASSWORD" | jq .

  # Still not sure what `owner` means.

  # # Can the user sign in?
  curl -v "${INFLUX_URL}/api/v2/signin" \
            --header "Authorization: Basic $legacy_auth_token:$INFLUX_USER_PASSWORD" | jq .

  org_owner=get_org_owners | jq --arg id $userid '.users[] | select(.id == $id)'

  if [ -z "$org_owner" ]; then
    # User isn't an owner.
    # Add the user to owners.
    org_owner=`add_org_owner $userid`
  fi

  echo "#### Org owner ID $org_owner"

  # org_owner_id=echo "$org_owner" | jq '.id'

  # # Try to get the task again, this time as an org owner.

  # curl -v "${INFLUX_URL}/api/v2/tasks/$taskid" \
  #            --header "Authorization: Basic $membername:$INFLUX_USER_PASSWORD" | jq .

  # delete_org_owner $userid

  # get_tasks_owners $taskid | jq --arg name $INFLUX_USER_NAME '.users[] | select(.name == $name)'
}

test_task_owner_basic_auth

function test_task_owner_token_auth {
    # 1. Get a task owner user ID and username.
  taskid=`get_tasks | jq -r '.tasks[0].id'`
  owners=`get_tasks_owners $taskid`
  owner=`echo "$owners" | jq -r '.users[1]'`
  echo "$owner"
  userid=`echo "$owner" | jq -r '.id'`
  username=`echo "$owner" | jq -r '.name'`

  # 2. Is user a member of the org? There's no method for this, so dig into the list.
  members=`curl -v --request GET \
                 "${INFLUX_URL}/api/v2/orgs/$INFLUX_ORG_ID/members" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
   --header 'Content-type: application/json'`

  member=`echo "$members" | jq --arg id $userid '.users[] | select(.id == $id)'`
  echo "$member" | jq '.'

  if [ -z "$member" ]; then
    # User isn't a member.
    # Add the user to members.
    member=`add_member $userid`
  fi

  membername=`echo "$member" | jq -r '.name'`

  # 4. Use token auth to get the task.

  curl -v "${INFLUX_URL}/api/v2/tasks/$taskid" \
             --header "Authorization: Token $INFLUX_READ_WRITE_TOKEN" | jq .
}

# test_task_owner_token_auth