function getRoutesForOp() {
  curl -vv "${INFLUX_URL}/api/v2" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}
getRoutesForOp

function getRoutesForAllAccess() {
  curl -vv "${INFLUX_URL}/api/v2" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}"
}
# getRoutesForAllAccess

function getRoutesForReadWrite() {
  curl -vv "${INFLUX_URL}/api/v2" \
   --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}
# getRoutesForReadWrite
