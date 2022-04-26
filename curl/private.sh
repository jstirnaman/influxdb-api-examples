function getLegacyAuths() {
  curl -vv -request GET \
  "${INFLUX_URL}/private/legacy/authorizations" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}
getLegacyAuths

####DEMO_DATA_ORG

#####
# All-Access Token can read all tokens of its org, including the Op token.
# All-Access Token can't read any tokens of a different org. Returns empty array.
#####

# Filter results by authorization ID.

# curl --request GET \
# 	"http://localhost:8086/api/v2/authorizations/${INFLUX_AUTH_ID}" \
 #  --header "Authorization: Token ${INFLUX_TOKEN}" \
 # --header 'Content-type: application/json'

######################################################
# The example below uses common command-line tools
# `curl`, `jq`, and `|` with the InfluxDB API.
# 1. Create a user and build an authorization object for the user ID.
# 2. Create the new authorization.
# 3. Return the new token.
# 4. List
######################################################

# List all users names.
#curl --request GET \
#  "http://localhost:8086/api/v2/users" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' | \

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

#curl -vv --request GET \
#  "http://localhost:8086/metrics" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' | grep auth

#
#curl -vv --request POST \
#  "http://localhost:8086/api/v2/users" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{ "name": "Test1 User" }' | \
#
#jq '{"orgID": "", "userID": .id, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' # | \
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

# Delete a user.
# curl --request DELETE \
#	"http://localhost:8086/api/v2/users/" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{"name": "user2"}' \
#  | jq .
#  | jq '.[0] | {orgID: "", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' | \

# Create a user.

# curl --request DELETE \
#	"http://localhost:8086/api/v2/users/" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{"name": "user2"}' \
#  | jq '.[0]
##  | jq '.[0] | {orgID: "", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' | \

# Delete a user.
# curl --request DELETE \
#	"http://localhost:8086/api/v2/users/" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{"name": "user2"}' \
#  | jq .
#  | jq '.[0] | {orgID: "", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' | \
#
#
# curl --request POST \
#	"http://localhost:8086/api/v2/authorizations" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
  # --data '{"orgID": "", "user": "user1", "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }'
#
#
#curl --request GET \
#	"http://localhost:8086/api/v2/authorizations?user=user1" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json'
