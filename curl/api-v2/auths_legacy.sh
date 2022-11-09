#!/bin/bash

function get_legacy_auths() {
  query=""
  curl --request GET \
 	"${INFLUX_URL}/private/legacy/authorizations$query" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'Content-type: application/json'
}

function create_legacy_auth() {
  curl -v "$INFLUX_URL/private/legacy/authorizations" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --data-binary @- << EOF
      {
        "orgID": "$INFLUX_ORG_ID",
        "permissions": [{"action": "read",
                         "resource": {
                            "type": "buckets"
                          }
                        }],
        "token": "${INFLUX_USER_NAME}-auth1",
        "userID": "$INFLUX_USER_ID"
      }
EOF
}

# Signin with legacy auth and password
function signin_basic() {
  curl -v --request POST "${INFLUX_URL}/api/v2/signin/" \
          --header "Authorization: Basic ${INFLUX_LEGACY_AUTH}:${INFLUX_USER_PASSWORD}"
}

# Helpers

function get_authorizations() {
  query=$1

  curl -v "$INFLUX_URL/api/v2/authorizations$query" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_users() {
  query=$1

  curl -v "$INFLUX_URL/api/v2/users$query" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}

get_legacy_auths | jq '.'
get_authorizations | jq --arg token $INFLUX_API_TOKEN '.authorizations[] | select(.token == $token)'

# Use the user name to the get the ID
INFLUX_USER_ID=`get_users "?name=$INFLUX_USER_NAME" | jq -r '.users[0].id'`
echo $INFLUX_USER_ID
# Create a legacy auth for the user ID
create_legacy_auth | jq '.'
