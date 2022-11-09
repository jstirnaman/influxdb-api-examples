#!/bin/bash

timestamp=`date +%s`;

# Signin
function signin_basic() {
curl -v --request POST \
               "${INFLUX_URL}/api/v2/signin" \
         --user "${INFLUX_USER_NAME}:${INFLUX_PASSWORD}" \
         | jq .
	       # --header "Authorization: Basic ${INFLUX_USER_NAME}:${INFLUX_PASSWORD}" | jq .
}

# Filter results by org ID.
# Reading authorizations requires permission to read authorizations and
# permission to read the users that the authorizations are scoped to.
function get_auths() {
  params=$1
  curl -v --request GET \
 	"${INFLUX_URL}/api/v2/authorizations$params" \
    --header "Authorization: Token $INFLUX_API_TOKEN" \
    --header 'Content-type: application/json' \
    | jq .

# basic=$(echo "${INFLUX_USER_NAME}:${INFLUX_ALL_ACCESS_TOKEN}" | base64)
#   curl -vv --request GET \
#  	"${INFLUX_URL}/api/v2/authorizations?orgID=${INFLUX_ORG}" \
#     --header "Authorization: Basic ${basic}" \
#     --header 'Content-type: application/json' \
#     | jq .
}

function update() {
  auth=`curl -v --request POST \
    "${INFLUX_URL}/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOF | jq -r .
      {
      "orgID": "$INFLUX_ORG_ID",
      "org": "foo-org",
      "permissions": [
          {
          "action": "read",
          "resource": { "type": "tasks" }
          }
        ]
      }
EOF
`

  authid=`echo $auth | jq -r .id`

  # It should not add a permission with only a resource name.
  curl --request PATCH \
    "${INFLUX_URL}/api/v2/authorizations/$authid" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOL | jq .
      {
        "permissions": [
          {
          "action": "read",
          "resource": { "name": "bucket1" }
          }
        ]
      }
EOL

  # It should not add a permission with a resource name and type.
  curl --request PATCH \
    "${INFLUX_URL}/api/v2/authorizations/$authid" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOL | jq .
      {
        "permissions": [
          {
          "action": "read",
          "resource": { "type": "buckets", "name": "bucket1"}
          }
        ]
      }
EOL

  # It should not add a permission with a resource name and ID mismatch.
  curl --request PATCH \
    "${INFLUX_URL}/api/v2/authorizations/$authid" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOL | jq .
      {
        "permissions": [
          {
          "action": "read",
          "resource": { "type": "buckets", "name": "bucket1", "id": "${BUCKET_ID}"}
          }
        ]
      }
EOL

  # It should not add a permission for a resource.
  curl -v --request PATCH \
    "${INFLUX_URL}/api/v2/authorizations/$authid" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOL | jq .
      { "orgID": "${INFLUX_ORG_ID}",
        "permissions": [
          {
          "action": "read",
          "resource": { "type": "buckets"}
          }
        ]
      }
EOL
}

function create() {

  echo "\nOperator token should create an auth for any resource type."
  curl -v --request POST \
    "$INFLUX_URL/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" \
    --header 'Content-Type: application/json' \
    --data @- << EOF | jq .
     {  "orgID": "${INFLUX_ORG_ID}",
        "description": "test-read-write-${timestamp}",
        "permissions": [
           {"action": "read",
            "resource": {"type": "orgs"}
            },
           {"action": "read",
            "resource": {"type": "buckets"}
            },
           {"action": "read",
            "resource": {"type": "users"}
            },
           {"action": "write",
            "resource": {"type": "buckets"}
           },
           {"action": "write",
            "resource": {"type": "users"}
           }
         ]
      }
EOF

  echo "\n With a non-operator token, it should not grant read-authorizations permissions."
  users=`curl -v --request GET "$INFLUX_URL/api/v2/users" \
    --header "Authorization: Token $INFLUX_API_TOKEN" \
    --header 'Content-Type: application/json' | jq .`

  USER_ID=`echo "$users" | jq -r '.users[0]'`
  curl -v --request POST \
    "$INFLUX_URL/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_API_TOKEN" \
    --header 'Content-Type: application/json' \
    --data @- << EOF | jq .
     {  "orgID": "${INFLUX_ORG_ID}",
        "description": "test-read-auths-${timestamp}",
        "permissions": [
           {"action": "read",
            "resource": {"type": "authorizations"}
            },
          {"action": "read",
            "resource": { "type": "users", "id": "${USER_ID}" },
            "orgID": "{$INFLUX_ORG_ID}"
          }
         ]
      }
EOF

  echo "\n It should not create an auth without a type."
  curl -v --request POST \
    "$INFLUX_URL/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" \
    --header 'Content-Type: application/json' \
    --data @- << EOF | jq .
     {  "orgID": "${INFLUX_ORG_ID}",
        "description": "all-access-${timestamp}",
        "permissions": [
           {"action": "read",
            "resource": { "id": "${BUCKET_ID}" }
            }
         ]
      }
EOF

  echo "It should create an auth with a resource ID."
  curl -v --request POST \
    "$INFLUX_URL/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" \
    --header 'Content-Type: application/json' \
    --data @- << EOF | jq .
     {  "orgID": "${INFLUX_ORG_ID}",
        "description": "all-access-${timestamp}",
        "permissions": [
           {"action": "read",
            "resource": { "type": "buckets", "id": "${BUCKET_ID}" },
            "orgID": "${INFLUX_ORG_ID}"
          }
         ]
      }
EOF

  echo "It should not create an auth for a resource name without an ID."
  curl -v --request POST \
    "$INFLUX_URL/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" \
    --header 'Content-Type: application/json' \
    --data @- << EOF | jq .
     {  "orgID": "${INFLUX_ORG_ID}",
        "description": "all-access-${timestamp}",
        "permissions": [
           {"action": "read",
            "resource": { "type": "buckets", "name": "bucket1" }
            }
         ]
      }
EOF

}

# Delete the first authorization listed for the user.
function delete() {
curl --request GET \
  "${INFLUX_URL}/api/v2/authorizations?user=user2" \
  --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
  --header 'Content-type: application/json' \
| jq .authorizations[0].id \
| xargs -I authid curl --request DELETE \
  "${INFLUX_URL}/api/v2/authorizations/authid" \
  --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
  --header 'Content-type: application/json'
}

######################################################
# The example below uses common command-line tools
# `curl`, `jq` with the InfluxDB API to do the following:
# 1. Create a user.
# 2. Find the new or existing user by name.
# 3. If the user exists:
#   a. Build an authorization object with the user ID.
#   b. Create the new authorization.
#   c. Return the new token.
######################################################

# Replace the following in the sample code:
#  - INFLUX_ORG_ID: the ID of the organization.
#  - INFLUX_TOKEN: an API token with permission to create users and authorizations--for example, an **Operator** token.

function create_token_scoped_to_user() {
  username=$1

  # Find the user with the provided name and extract the user ID.
  user=`curl --request GET \
    "http://localhost:8086/api/v2/users?name=$username" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" | \
    jq '.users[0]'`

  # If the user doesn't exist, create a user with the provided name.
  if [ "$user" == "null" ]; then
    user=`curl --request POST \
      "http://localhost:8086/api/v2/users" \
      --header "Authorization: Token $INFLUX_OP_TOKEN" \
      --header 'Content-type: application/json' \
      --data "{\"name\": \"$username\"}"`
  fi

  userid=`echo "$user" | jq -r '.id'`

  # Create an authorization scoped to the user and then output the API token.
  # The authorization grants the read-buckets permission.
  jq -r -n --arg USERID $userid --arg INFLUX_ORG_ID $INFLUX_ORG_ID \
     '{
        "orgID": $INFLUX_ORG_ID,
        "userID": $USERID,
        "description": "iot_users read buckets",
        "permissions": [
           {"action": "read", "resource": {"type": "buckets"}}
         ]
      }' | \
  curl -v --request POST \
    "$INFLUX_URL/api/v2/authorizations" \
    --header "Authorization: Token $INFLUX_OP_TOKEN" \
    --header 'Content-Type: application/json' \
    --data @- | \
  jq -r '.token'
}

# signin_basic
# create_token_scoped_to_user 'iot_user_112'
# get_auths
# create
# get_auths "?orgID=${INFLUX_ORG_ID}"

# It should fetch the specified auth.
# AUTH_ID=`get_auths | jq -r '.authorizations[0].id'`
# get_auths "/$AUTH_ID"

# It should fetch itself.
# get_auths | jq --arg token $INFLUX_API_TOKEN '.authorizations[] | select(.token == $token)'

# create

# API_TOKEN=$INFLUX_API_TOKEN
# AUTHS=`get_auths`
# echo "$AUTHS" | jq '.authorizations | length'
# echo "$AUTHS" | jq '.authorizations[] | .token'
# echo "$AUTHS" | jq --arg token $API_TOKEN '.authorizations'

# get_auths "/$AUTH_ID"

# Cloud: It should use the token param to fetch itself.
get_auths "?token=$INFLUX_API_TOKEN"

# update