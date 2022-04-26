source "./oss.env"
#source "./cloud.env"

function listUsers() {
echo "=== USERS ==="
curl --request GET \
               "${INFLUX_URL}/api/v2/users/" \
 --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
 --header 'Content-type: application/json' | jq .
}

function listMembers() {
  echo "=== MEMBERS ==="
  curl --request GET \
                 "${INFLUX_URL}/api/v2/orgs/$INFLUX_ORG/members/" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function findUser() {
  curl --request GET \
                 "${INFLUX_URL}/api/v2/users/$1" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function findMe() {
  echo "=== Find me ==="
  id=$(curl --request GET \
                 "${INFLUX_URL}/api/v2/me/" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
   --header 'Content-type: application/json' | jq . | jq .id)

  echo "Got me: ${id}"
}
findMe

function createUser() {
  name="buddy$RANDOM"

  # echo "Creating user: ${name}"
  user=$(curl --trace trace.out --request POST \
  "${INFLUX_URL}/api/v2/users/" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
   --header 'Content-type: application/json' \
   --data-binary @- << EOF | jq .
   {
     "name": "${name}",
     "status": "active"
   }
EOF
  )

  #echo "Got new user: ${user}"
  id=$(echo "${user}" | jq -r '. | .id')
  #echo "with ID: ${id}"
  # echo "Setting password"
  curl --trace trace.out --request POST \
    "${INFLUX_URL}/api/v2/users/${id}/password/" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data '{ "password": "password1" }'

  echo $user
}
 # --header "Authorization: Basic ${INFLUX_USER_OWNER}:${INFLUX_ALL_ACCESS_TOKEN}"


# Delete a user.
function deleteUser() {
 curl --request DELETE \
  "${INFLUX_URL}/api/v2/users/" \
  --header "Authorization: Token ${INFLUX_TOKEN}" \
  --header 'Content-type: application/json' \
  --data '{"name": "user2"}' \
  | jq . \
  | jq `.[0] | {orgID: "${INFLUX_ORG}", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }`
}
# deleteUser

# Signin
function signin() {
#echo "Signing in user: $1"
  curl -vv --request POST \
         "${INFLUX_URL}/api/v2/signin/" \
         --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
         -u "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}"
}
signin

function createMember() {
  # echo "Adding user ${2} to org $1"
  org=$1
  # id=$2

  id=0772396d1f41100

  curl --trace trace.out --request POST \
    "${INFLUX_URL}/api/v2/orgs/$org/members/" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOF | jq .
    { "id": "${id}" }
EOF
}

function createNewMemberSession() {
  user=$(create)
  id=$(echo "${user}" | jq -r '. | .id')
  name=$(echo "${user}" | jq -r '. | .name')
  member=$(add_member $INFLUX_ORG $id)
  signin $name
}
# createNewMemberSession

function signinBasicAuth() {
  basicCreds="${INFLUX_USER_NAME}:${INFLUX_READ_WRITE_TOKEN}"
  curl -vv --request POST \
   	"${INFLUX_URL}/api/v2/signin" \
    --header "Authorization: Basic ${basicCreds}" \
    --header 'Content-type: application/json'
}
#signinBasicAuth

# Filter results by org ID.
# curl --request GET \
# 	"http://localhost:8086/api/v2/authorizations?orgID=${INFLUX_ORG}" \
# --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}" \
# --header 'Content-type: application/json'

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

# Delete a user.
# curl --request DELETE \
#	"http://localhost:8086/api/v2/users/" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{"name": "user2"}' \
#  | jq .
#  | jq '.[0] | {orgID: "48c88459ee424a04", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' | \

# Create a user.

# curl --request DELETE \
#	"http://localhost:8086/api/v2/users/" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{"name": "user2"}' \
#  | jq '.[0]
##  | jq '.[0] | {orgID: "48c88459ee424a04", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' | \

# Delete a user.
# curl --request DELETE \
#	"http://localhost:8086/api/v2/users/" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
#  --data '{"name": "user2"}' \
#  | jq .
#  | jq '.[0] | {orgID: "48c88459ee424a04", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }' | \
#
#
# curl --request POST \
#	"http://localhost:8086/api/v2/authorizations" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json' \
  # --data '{"orgID": "48c88459ee424a04", "user": "user1", "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }'
#
#
#curl --request GET \
#	"http://localhost:8086/api/v2/authorizations?user=user1" \
#  --header "Authorization: Token ${INFLUX_TOKEN}" \
#  --header 'Content-type: application/json'
