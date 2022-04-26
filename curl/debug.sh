function debug() {
  curl -vv "${INFLUX_URL}/debug/pprof" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
   --header "Accept: application/json"
}
debug
