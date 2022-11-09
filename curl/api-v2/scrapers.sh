timestamp=`date +%s`;

# InfluxDB default is 100.

function get_scrapers() {
  PARAMS="${1}"

  curl -v --request GET \
    "${INFLUX_URL}/api/v2/scrapers${PARAMS}" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_scrapers_after() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers?after=${1}" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_scrapers_by_name() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers?name=scraper1" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_scrapers_by_status() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers?status=${1}" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}
# get_scrapers_by_status inactive
# get_scrapers_by_status active

# https://docs.influxdata.com/influxdb/v2.3/reference/release-notes/influxdb/#scraper-metadata
function get_scrapers_as() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers?limit=100" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}" | jq '. | .scrapers'
}
# get_scrapers_as basic
# get_scrapers_as system

flux="from(bucket: params.bucket)
                 |> range(start: duration(v: params.rangeStart))
                 |> filter(fn: (r) => r._field == params.filterField)
                 |> group(columns: [params.groupColumn])"

function create_scraper_cloud() {
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/scrapers" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF | jq .
    {
    "every": "60m",
    "description": "IoT Center environment running average.",
    "name": "30-day-avg",
    "scriptID": "09b2136232083000",
    "scriptParameters":
      {
        "rangeStart": "scraper.every",
        "bucket": "air_sensor",
        "filterField": "temperature",
        "groupColumn": "_time"
      }
    }
EOF
}

function create_script_scraper_cloud() {
  SCRIPT_ID=$(
  curl "${INFLUX_URL}/api/v2/scripts" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data-binary @- << EOF | jq -r '.id'
    {
      "name": "filter-and-group21",
      "description": "Returns filtered and grouped points from a bucket.",
      "script": "from(bucket: params.bucket)\
                 |> range(start: duration(v: params.rangeStart))\
                 |> filter(fn: (r) => r._field == params.filterField)\
                 |> group(columns: [params.groupColumn])",
       "language": "flux"
    }
EOF
)

echo $SCRIPT_ID

curl -v $INFLUX_URL/api/v2/scrapers \
--header "Content-type: application/json" \
--header "Authorization: Token $INFLUX_API_TOKEN" \
--data @- << EOF
  {
  "name": "avg scraper",
  "every": "60m",
  "scriptID": "${SCRIPT_ID}",
  "scriptParameters":
    {
      "rangeStart": "-30d",
      "bucket": "air_sensor",
      "filterField": "temperature",
      "groupColumn": "_time"
    }
  }
EOF
}

function update_scraper() {
  curl -v --request PATCH \
    "${INFLUX_URL}/api/v2/scrapers/${1}" \
    --header "Content-type: application/json" \
    --header "Authorization: Token ${INFLUX_API_TOKEN}" \
    --data-binary @- << EOF | jq .
      {
        "description": "IoT Center 30d environment average.",
        "flux":  "option scraper = {name: \"iot-center-scraper-3\", every: 60s} \
                  from(bucket: \"air_sensor\") \
                      |> range(start: 1h) \
                      |> filter(fn: (r) => r._field == \"temperature\") \
                      |> group(columns: [\"_time\"])",
        "status": "active"
      }
EOF
}

function update_scrapers() {
  arr_ids=$(get_scrapers '?limit=10' | jq -r '[.["scrapers"][].id]|@tsv')
  for id in $arr_stackids
  do
    curl -v --request PATCH "$INFLUX_URL/api/v2/scrapers/$id" \
      --header "Authorization: Token $INFLUX_OP_TOKEN" \
      --header "Content-type: application/json" \
      --data @- << EOF
      {
        "name": "project-scraper-$id"
      }
EOF
    get_scrapers_by_name project-stack-$id | jq '.["scrapers"]'
  done
}

function delete_scraper() {
  curl -v --request DELETE \
	"${INFLUX_URL}/api/v2/scrapers/${1}" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function delete_scrapers() {
  arr_ids=$(get_scrapers '?limit=180' | jq -r '[.["configurations"][].id]|@tsv')
  for id in $arr_ids
  do
    curl -v --request DELETE "$INFLUX_URL/api/v2/scrapers/$id" \
      --header "Authorization: Token $INFLUX_OP_TOKEN" \
      --header "Content-type: application/json"
  done
}

function get_scraper_runs() {
  query=$2

  curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers/${1}/runs${query}" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_scraper_run() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers/${1}/runs/${2}" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_scraper_run_logs() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers/${1}/runs/${2}/logs" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function get_scraper_logs() {
  curl -v --request GET \
	"${INFLUX_URL}/api/v2/scrapers/${1}/logs" \
        --header "Content-type: application/json" \
	--header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function run_scraper() {
  curl -v --request POST \
	  "${INFLUX_URL}/api/v2/scrapers/${1}/runs" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

# Cancel a scraper run.
function cancel_run() {
    curl -v --request DELETE \
	  "${INFLUX_URL}/api/v2/scrapers/${1}/runs/${2}" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

function retry_run() {
    curl -v --request POST \
	  "${INFLUX_URL}/api/v2/scrapers/${1}/runs/${2}/retry" \
    --header "Content-type: application/json" \
	  --header "Authorization: Token ${INFLUX_API_TOKEN}"
}

# delete_scrapers
get_scrapers | jq '. | .configurations | length'

