INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

function listUsers() {
query=$1

curl --request GET \
               "${INFLUX_URL}/api/v2/users$1" \
 --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
 --header 'Content-type: application/json'
}

function listMembers() {
  curl --request GET \
                 "${INFLUX_URL}/api/v2/orgs/$INFLUX_ORG/members/" \
   --header "Authorization: Token ${INFLUX_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function findUser() {
  curl --request GET \
                 "${INFLUX_URL}/api/v2/users/$1" \
   --header "Authorization: Token ${INFLUX_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function findMe() {
  echo "=== Find me ==="
  curl --request GET \
                 "${INFLUX_URL}/api/v2/me/" \
   --header "Authorization: Token ${INFLUX_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

# --header "Authorization: Basic ${INFLUX_USER_OWNER}:${INFLUX_ALL_ACCESS_TOKEN}"

function createUser() {
        USER_NAME="buddy$RANDOM"
        USER_ID=$(curl -v --request POST \
                  "http://localhost:8086/api/v2/users/" \
                  --header "Authorization: Token $INFLUX_OP_TOKEN" \
                  --header 'Content-type: application/json' \
                  --data-binary @- << EOF | jq -r '.id'
                  {
                    "name": "$USER_NAME",
                    "status": "active"
                  }
EOF
        )

        # Pass the user ID to create a password for the user.
        curl -v request POST "http://localhost:8086/api/v2/users/$USER_ID/password/" \
          --header "Authorization: Token $INFLUX_OP_TOKEN" \
          --header 'Content-type: application/json' \
          --data '{ "password": "USER_PASSWORD" }'
}

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
         --header "Authorization: Token ${INFLUX_TOKEN}" \
         -u "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}"
}
# signin

function createMember() {
  # echo "Adding user ${2} to org $1"
  org=$1
  # id=$2

  id=0772396d1f41100

  curl --trace trace.out --request POST \
    "${INFLUX_URL}/api/v2/orgs/$org/members/" \
    --header "Authorization: Token ${INFLUX_TOKEN}" \
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

function updateUserPassword() {
  basicCreds="${INFLUX_USER_NAME}:${INFLUX_TOKEN}"
  curl -vv --request POST \
   	"${INFLUX_URL}/api/v2/users/${1}/password/" \
    --header "Authorization: Basic ${basicCreds}" \
    --header 'Content-type: application/json'
}

function updateUserPasswordBasicAuth() {
  basicCreds="${INFLUX_USER_NAME}:${INFLUX_TOKEN}"
  curl -v --request POST \
   	"${INFLUX_URL}/api/v2/users/${1}/password" \
    --header "Authorization: Basic ${basicCreds}" \
    --header 'Content-type: application/json'
}

listUsers "?limit=100" | jq '.users | length'

