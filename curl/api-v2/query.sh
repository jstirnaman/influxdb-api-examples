export INFLUX_BUCKET=air_sensor

function query() {
  basic=$(echo "${INFLUX_USER_NAME}:${INFLUX_ALL_ACCESS_TOKEN}" | base64)

  # curl -vv --request POST \
  #   "${INFLUX_URL}/api/v2/query?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=s" \
  #   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
  #   --header 'Content-type: application/vnd.flux' \
  #   --header 'Accept: application/csv' \
  #   --data 'from(bucket:"air_sensor")
  #        |> range(start: -30d)
  #        |> filter(fn: (r) => r._measurement == "airSensors")' \
  #  | grep .

  curl -vv --request POST \
   "${INFLUX_URL}/api/v2/query?org=${INFLUX_ORG}&bucket=${INFLUX_BUCKET}&precision=s" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
   --header 'Content-type: application/vnd.flux' \
   --header 'Accept: application/json' \
   --data 'from(bucket:"_tasks")
        |> range(start: -100d)
        |> filter(fn: (r) => r._measurement == "runs")' \
	| grep .
#   --data 'from(bucket:"air_sensor")
#        |> range(start: -100d)
#        |> filter(fn: (r) => r._measurement == "airSensors")' \
#  | grep .


}
query
