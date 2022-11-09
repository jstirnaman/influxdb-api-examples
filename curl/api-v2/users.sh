#!/bin/bash -e

function list_users() {
  params=$1

  curl --request GET \
  "${INFLUX_URL}/api/v2/users$params" \
  --header "Authorization: Token $INFLUX_API_TOKEN" \
  --header 'Content-type: application/json'
}

function list_members() {
  curl --request GET \
   "${INFLUX_URL}/api/v2/orgs/$INFLUX_ORG/members/" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function find_user() {
  params=$1
  curl --request GET \
                 "${INFLUX_URL}/api/v2/users$params" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function find_me_token() {
  echo "\n\n ### Token auth"
  curl --request GET \
                 "${INFLUX_URL}/api/v2/me" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" \
   --header 'Content-type: application/json' | jq .
}

function find_me_basic() {
  echo "\n\n ### Basic auth"
  curl -v --request GET \
        "$INFLUX_URL/api/v2/me" \
        --user "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}"
}

function find_me_session() {
  echo "\n\n ### Session auth"
  curl -v --request GET \
       -b ./cookie-file.tmp \
       "$INFLUX_URL/api/v2/me"
}

function create_user() {
        USER_ID=$(curl -v --request POST \
                  "$INFLUX_URL/api/v2/users/" \
                  --header "Authorization: Token $INFLUX_API_TOKEN" \
                  --header 'Content-type: application/json' \
                  --data-binary @- << EOF | jq -r '.id'
                  {
                    "name": "$USER_NAME",
                    "status": "active"
                  }
EOF
        )

       # Pass the user ID to create a password for the user.
        curl -v --request POST "$INFLUX_URL/api/v2/users/$USER_ID/password/" \
          --header "Authorization: Token $INFLUX_API_TOKEN" \
          --header 'Content-type: application/json' \
          --data '{ "password": "'"$INFLUX_USER_PASSWORD"'" }'
}

function update_user() {
  curl -v --request PATCH \
       "$INFLUX_URL/api/v2/users/$USER_ID" \
          --header "Authorization: Token $INFLUX_API_TOKEN" \
          --header 'Content-type: application/json' \
          --data-binary @- << EOF | jq -r '.id'
        {
          "oauthID": "my-oauth-id",
          "status": "inactive"
        }
EOF
}

# Delete a user.
function delete_user() {
 curl --request DELETE \
  "${INFLUX_URL}/api/v2/users/" \
  --header "Authorization: Token ${INFLUX_API_TOKEN}" \
  --header 'Content-type: application/json' \
  --data '{"name": "user2"}' \
  | jq . \
  | jq `.[0] | {orgID: "${INFLUX_ORG}", "user": .userID, "permissions":[{"action": "read", "resource": {"type": "buckets"}}] }`
}
# deleteUser

# Signin
function signin() {
  echo "\nSignin"
  curl -v --request POST \
         -c ./cookie-file.tmp \
         "$INFLUX_URL/api/v2/signin" \
        --user "${USER_NAME}:${INFLUX_USER_PASSWORD}"
}

# Signin
function signout() {
  echo "\nSignout"
  curl -v --request POST \
         -b ./cookie-file.tmp \
         "$INFLUX_URL/api/v2/signout"
}

function create_member() {
  echo "createMember"

  curl --request POST \
    "$INFLUX_URL/api/v2/orgs/$INFLUX_ORG_ID/members" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOF | jq .
    { "id": "${INFLUX_USER_ID}" }
EOF
}

function create_member_and_session() {
  user=$(create)
  id=$(echo "${user}" | jq -r '. | .id')
  name=$(echo "${user}" | jq -r '. | .name')
  member=$(add_member $INFLUX_ORG $id)
  signin $name
}

function signin_basic_auth() {
  echo "signinBasicAuth"
  curl -v -c ./cookie-file.tmp --request POST \
   	"$INFLUX_URL/api/v2/signin" \
    --user "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}" | jq .
}

function put_user_password_basicauth() {
  # Doesn't work - returns 401. Only allows token (or session?).
  echo $INFLUX_USER_NAME
  echo $INFLUX_USER_PASSWORD
  echo $INFLUX_USER_ID

  curl -v --request PUT \
   	"$INFLUX_URL/api/v2/users/$INFLUX_USER_ID/password" \
    --header 'Content-type: application/json' \
    --user "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}" \
    --data-binary @- << EOF
      {"password": "password1"}
EOF
}

function post_user_password_basicauth() {
  # Doesn't work - returns 401. Only allows token (or session?).
  echo $INFLUX_USER_NAME
  echo $INFLUX_USER_PASSWORD
  echo $INFLUX_USER_ID

  curl -v --request POST \
   	"$INFLUX_URL/api/v2/users/$INFLUX_USER_ID/password" \
    --header 'Content-type: application/json' \
    --user "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}" \
    --data-binary @- << EOF
      {"password": "password1"}
EOF
}

function post_user_password_sessionauth() {
  # Works for session auth
  signinBasicAuth

  curl --request POST \
    -b ./cookie-file.tmp \
   	"$INFLUX_URL/api/v2/users/$INFLUX_USER_ID/password" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOF
      {"password": "password1"}
EOF
}

function post_user_password_tokenauth() {
  echo "postUserPasswordTokenAuth"
  curl --request POST \
   	"$INFLUX_URL/api/v2/users/$INFLUX_USER_ID/password" \
    --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
    --header 'Content-type: application/json' \
    --data-binary @- << EOF
      {"password": "password1"}
EOF
}

function update_me_password_basicauth() {
# Doesn't work due to bug - always requires a user ID.
curl -v \
         -b ./cookie-file.tmp \
         --request PUT \
               "$INFLUX_URL/api/v2/me/password" \
         --header 'Content-type: application/json' \
         --user "${INFLUX_USER_NAME}:${INFLUX_USER_PASSWORD}" \
         --data-binary @- << EOF
           {"password": "$INFLUX_USER_PASSWORD"}
EOF
}

function test_should_signout_a_user_session() {
  echo "it should signout a user session"
  INFLUX_API_TOKEN=$INFLUX_OP_TOKEN
  USER_NAME="buddy$RANDOM"
  USER_ID
  createUser | jq .
  signin
  findMeSession
  signout
  findMeSession
}
