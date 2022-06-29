export INFLUX_BUCKET=airSensors
export FAKE_ORG_ID=34f334f34f34f434

cat <<EOF > task_runs_query
  from(bucket:"_tasks")
    |> range(start: -100d)
    |> filter(fn: (r) => r._measurement == "_runs")
EOF

cat <<EOF > airSensors_query
  from(bucket:"airSensors")
    |> range(start: -100d)
    |> filter(fn: (r) => r._measurement == "airSensor")
EOF

cat <<EOF > iot_center_environment
  from(bucket:"iot_center")
    |> range(start: -100d)
    |> filter(fn: (r) => r._measurement == "environment")
EOF

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
   "${INFLUX_URL}/api/v2/query?org=${FAKE_ORG_ID}&orgID=${FAKE_ORG_ID}&bucket=${INFLUX_BUCKET}&precision=s" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
   --header 'Content-type: application/vnd.flux' \
   --header 'Accept: application/csv' \
   --data @airSensors_query \
 | grep .
}
# query


function analyze() {
  curl -v --request POST \
   "${INFLUX_URL}/api/v2/query/analyze" \
   --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
   --header 'Content-type: application/json' \
   --header 'Accept: application/json' \
   --data-binary @- << EOF | jq .
     { "query": "from(bucket: \"iot_center\")\
                 |> range(start: -90d)\
                 |> filter(fn: (r) => r._measurement == \"environment\")",
        "type": "flux"
      }
EOF
}
analyze