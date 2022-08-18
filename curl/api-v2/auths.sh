#!/bin/bash

# Signin
function signin_basic() {
curl -vv --request POST \
               "${INFLUX_URL}/api/v2/signin/" \
	       --header "Authorization: Basic ${INFLUX_USER_NAME}:${INFLUX_ALL_ACCESS_TOKEN}" | jq .
}

# Filter results by org ID.
function get_auths() {
  curl --request GET \
 	"${INFLUX_URL}/api/v2/authorizations?orgID=${INFLUX_ORG}" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --header 'Content-type: application/json' \
    | jq .

basic=$(echo "${INFLUX_USER_NAME}:${INFLUX_ALL_ACCESS_TOKEN}" | base64)
  curl -vv --request GET \
 	"${INFLUX_URL}/api/v2/authorizations?orgID=${INFLUX_ORG}" \
    --header "Authorization: Basic ${basic}" \
    --header 'Content-type: application/json' \
    | jq .
}
get_auths

# Filter results by authorization ID.
function get_auth() {
  curl --request GET \
 	"${INFLUX_URL}/api/v2/authorizations/${INFLUX_AUTH_ID}" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --header 'Content-type: application/json' \
    | jq .
}

function getLegacyAuths() {
  curl -vv -request GET \
  "${INFLUX_URL}/private/legacy/authorizations" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}

function update() {
# Set the user's first authorization to `inactive`.
curl --request GET \
  "${INFLUX_URL}/api/v2/authorizations?user=user2" \
  --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
  --header 'Content-type: application/json' \
| jq .authorizations[0].id \
| xargs -I authid curl --request PATCH \
  "${INFLUX_URL}/api/v2/authorizations/authid" \
  --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
  --header 'Content-type: application/json' \
  --data '{
            "description": "deactivated_auth",
	    "status": "inactive"
          }' | jq .
}
#update


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
# The example below uses the common command-line tools `curl` and `jq`
# with the InfluxDB API to do the following:
# 1. Find a user by username and extract the user ID.
# 2. Find the user's authorizations by user ID.
# 3. Filter to active authorizations that have `write` permission.
######################################################

#USERNAME=my-test-user
#
#curl --request GET \
#  "http://localhost:8086/api/v2/users/?name=$USERNAME" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' | \
#
#jq --arg USER $USERNAME '.users[] | select(.name == $USER) | .id' | \
#
#xargs -I '%' curl -vv --request GET \
#  "http://localhost:8086/api/v2/authorizations/?userID=%" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' | \
#
#jq '.authorizations[] | select(.permissions[] | select(.action=="write")) | select(.status=="active")'

#
#curl -vv --request POST \
#  "http://localhost:8086/api/v2/users" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{ "name": "Test1 User" }' | \
#
#jq '{"orgID": "48c88459ee424a04", "userID": .id, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' # | \
#
#curl -vv --request POST \
#  "http://localhost:8086/api/v2/authorizations" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data @- | \
#
#jq '.userID' | \
#
# xargs -I '{0}' curl -vv --request GET \
# "http://localhost:8086/api/v2/authorizations/?userID={0}" \
#   --header "Authorization: Token ${INFLUX_TOKEN}" \
#   --header 'Content-type: application/json' 1> /dev/null # | \
#
# jq '.[]'

## List all tokens for the user name.
#
#curl --request GET \
#  "http://localhost:8086/api/v2/authorizations?user=user2" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' | \
#
#jq. '.authorizations[] | .token'

# Set the first authorization as `inactive`.
# jq '.authorizations[0].id'
#curl --request PATCH \
#  "http://localhost:8086/api/v2/authorizations/${@-}" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{
#            "description": "Deactiving user",
#	    "status": "inactive"
#          }' | jq .
#
# curl --request POST \
#	"http://localhost:8086/api/v2/authorizations" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
  # --data '{"orgID": "48c88459ee424a04", "user": "user1", "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }'
