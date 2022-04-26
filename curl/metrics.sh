 source "./oss.env"
#source "./cloud.env"

function getMetricsForOp() {
  curl -vv "${INFLUX_URL}/metrics" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}"
}
getMetricsForOp

function getMetricsForAllAccess() {
  curl -vv "${INFLUX_URL}/metrics" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}"
}
# getMetricsForAllAccess

function getMetricsForReadWrite() {
  curl -vv "${INFLUX_URL}/metrics" \
   --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}
# getMetricsForReadWrite
