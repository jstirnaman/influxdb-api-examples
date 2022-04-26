 source "./oss.env"
#source "./cloud.env"

function getHealthForOp() {
  curl -vv "${INFLUX_URL}/health" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}
getHealthForOp

function getHealthForAllAccess() {
  curl -vv "${INFLUX_URL}/health" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}"
}
# getHealthForAllAccess

function getHealthForReadWrite() {
  curl -vv "${INFLUX_URL}/health" \
   --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}
# getHealthForReadWrite
