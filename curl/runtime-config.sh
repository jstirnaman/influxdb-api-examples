function getServerConfig() {
  curl -vv "${INFLUX_URL}/api/v2/config" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}
getServerConfig

function getServerConfigForAllAccess() {
  curl -vv "${INFLUX_URL}/api/v2/config" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}"
}
getServerConfigForAllAccess

