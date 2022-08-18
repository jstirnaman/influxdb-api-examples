#!/bin/bash -e

source "./cloud.env"

INFLUX_API_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_ORG_ID=$INFLUX_ORG

SCRIPT="from(bucket: params.mybucket) |> range(start: -30d) |> limit(n:1)"

create_script() {
curl -v -X 'POST' \
  "${INFLUX_URL}/api/v2/scripts" \
  --header "Authorization: Token ${INFLUX_API_TOKEN}" \
  --header 'accept: application/json' \
  --header 'Content-Type: application/json' \
  --data-binary @- << EOF | jq .
  {
    "name": "myFirstNamedFunc",
    "description": "a named function that gathers the last point from a bucket",
    "orgID": "${INFLUX_ORG_ID}",
    "script": "${SCRIPT}",
    "language": "flux"
  }
EOF
}

# create_script

update_script() {
SCRIPT_ID=$1

curl -vv -X 'PATCH' \
  "${INFLUX_URL}/api/v2/scripts/${SCRIPT_ID}" \
  --header "Authorization: Token ${INFLUX_API_TOKEN}" \
  --header 'accept: application/json' \
  --header 'Content-Type: application/json' \
  --data-binary @- << EOF | jq .
  {
    "name": "findLastPoint",
    "description": "a named function that gathers the last point from a bucket",
    "script": "${SCRIPT}"
  }
EOF
}

find() {
  SCRIPT_ID="$1"

  curl -X 'GET' \
    "${INFLUX_URL}/api/v2/scripts/${SCRIPT_ID}" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'accept: application/json' \
    --header 'Content-Type: application/json' | jq .
}

list() {
  curl -X 'GET' \
    "${INFLUX_URL}/api/v2/scripts" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'accept: application/json' \
    --header 'Content-Type: application/json' \
    --data-urlencode 'org=jstirnamaninflux&limit=10' | jq .
}

find_and_update() {
  FIND_TEXT="-7d"
  REPLACE_TEXT="params.range"

  curl -X 'GET' \
    "${INFLUX_URL}/api/v2/scripts" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'accept: application/json' \
    --header 'Content-Type: application/json' \
    --data-urlencode 'org=jstirnamaninflux&limit=10' \
    | jq .['script']
}

invoke_post() {
  SCRIPT_ID=$1

  curl -vv -X 'POST' \
    "${INFLUX_URL}/api/v2/scripts/${SCRIPT_ID}/invoke" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'Accept: application/csv' \
    --header 'Content-Type: application/json' \
    --data-binary '{ "params": { "mybucket": "air_sensor" } }'
}

## Add and invoke a script, takes two params.
create_invoke_with_params() {
new_script_id=$(
  curl -v -X 'POST' \
    "${INFLUX_URL}/api/v2/scripts" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data-binary @- << EOF | jq -r '.id'
    {
      "name": "noDesc",
      "description": "Returns filtered and grouped points from a bucket.",
      "script": "from(bucket: params.bucket) \
		 |> range(start: duration(v: params.rangeStart)) \
                 |> filter(fn: (r) => r._field == params.filterField or r._field == params.filterField2) \
                 |> group(columns: [params.groupColumn])",
       "language": "flux"
    }
EOF
     # "script": "from(bucket: params.bucket) \
     #            |> range(start: -30d) \
     #            |> filter(fn: (r) => r._field == params.filterField) \
     #            |> limit(n: params.pointsLimit) \
     #            |> group(columns: [params.groupField])",
)

echo $new_script_id
 curl -v
     "${INFLUX_URL}/api/v2/scripts/${new_script_id}/invoke" \
     --header "Authorization: Token ${INFLUX_API_TOKEN}" \
     --header 'Accept: application/csv' \
     --header 'Content-Type: application/json' \
     --data-binary @- << EOF
       { "params":
         {
	   "rangeStart": "-30d",
           "bucket": "air_sensor",
           "filterField": "temperature",
           "filterField2": "humidity",
           "groupColumn": "_time"
         }
       }
EOF
}

create_invoke_with_params

delete() {
  ## Get first script ID from list.
  script_id=$(list | jq -r '.scripts[0] | .id')
  #SCRIPT_ID="$1"
  SCRIPT_ID=$script_id

  curl -v -X 'DELETE' \
    "${INFLUX_URL}/api/v2/scripts/${SCRIPT_ID}" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}"
}
