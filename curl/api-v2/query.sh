export FAKE_ORG_ID=12ecfe5b8de761f8

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
  INFLUX_API_TOKEN=$INFLUX_READ_WRITE_TOKEN
  basic=$(echo "${INFLUX_USER_NAME}:${INFLUX_API_TOKEN}" | base64)

  ORG_NAME=FAKE_ORG_ID
  ORG_ID=FAKE_ORG_ID
  curl -vv --request POST \
   "${INFLUX_URL}/api/v2/query?org=${INFLUX_ORG}&orgID=${INFLUX_ORG_ID}&bucket=${INFLUX_BUCKET}&precision=s" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" \
   --header 'Content-type: application/vnd.flux' \
   --header 'Accept: application/csv' \
   --data @airSensors_query \
 | grep .
}

function query_flux_sql() {
curl --request POST \
"$INFLUX_URL/api/v2/query" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: application/vnd.flux" \
  --header "Accept: application/csv" \
  --data "
    import \"experimental/iox\"

    iox.sql(
        bucket: \"${INFLUX_BUCKET}\",
        query: \"
            SELECT
              *
            FROM
              home
            WHERE
              time >= '2023-03-09T08:00:00Z'
              AND time <= '2023-03-16T20:00:00Z'
        \",
    )"

}

function analyze() {
  curl -v --request POST \
   "${INFLUX_URL}/api/v2/query/analyze" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" \
   --header 'Content-type: application/json' \
   --header 'Accept: application/json' \
   --data-binary @- << EOF | jq .
     { "query": "from(foo: \"iot_center\")\
                 |> range(start: -90d)\
                 |> filter(fn: (r) => r._measurement == \"environment\")",
        "type": "flux"
      }
EOF
}

function get_suggestions() {
  curl -v --request GET \
   "${INFLUX_URL}/api/v2/query/suggestions" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" \
   --header 'Content-type: application/json' \
   --header 'Accept: application/json' \
 | jq .
}

function query_ast() {
curl --request POST "$INFLUX_URL/api/v2/query/ast" \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--header "Authorization: Token $INFLUX_API_TOKEN" \
--data-binary @- << EOL
    {
      "query": "from(bucket: \"$INFLUX_BUCKET_NAME\")\
      |> range(start: -5m)\
      |> filter(fn: (r) => r._measurement == \"example-measurement\")"
    }
EOL
}

query_flux_sql