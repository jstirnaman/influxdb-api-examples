#!/bin/bash -e
V1_QUERY=/query?;
V1_WRITE=/write?;

export V1_DB="b1_db";

# curl -v --request GET \
#	"${INFLUX_URL}/api/v2/buckets?orgID=${INFLUX_ORG_ID}" \
#	--header "Authorization: Token ${INFLUX_TOKEN}";



echo "v1.0 requests";

timestamp=`date +%s`;
# V1 Compat: <1.x username>:<token> works until you `auth v1 set-password`. Then
# you must use <1.x username>:<1.x password>
curl -vv --request POST "${INFLUX_URL}${V1_WRITE}db=${V1_DB}&precision=s" \
  --header "Authorization: Token ${INFLUX_TOKEN}" \
    --data-raw "mem,host=host1 used_percent=$((1 + $RANDOM % 100)) ${timestamp}
  mem,host=host2 used_percent=$((1 + $RANDOM % 100)) ${timestamp}
  mem,host=host1 used_percent=$((1 + $RANDOM % 100)) ${timestamp}
  mem,host=host2 used_percent=$((1 + $RANDOM % 100)) ${timestamp}
  "
    # --user "${USER}:${INFLUX_PASS}" \
    # --data-urlencode "q=SELECT * _measurement" | jq .
    # --header "Authorization: Token ${INFLUX_TOKEN}"

# Query with default retention policy
# curl -v --get "${INFLUX_URL}${V1_QUERY}" \
#  --user "${USER}:${INFLUX_TOKEN}" \
#  --data-urlencode "db=${V1_DB}" \
#  --data-urlencode "epoch=s" \
#  --data-urlencode "q=SELECT used_percent FROM mem" | jq .

  # --user "${USER}:${INFLUX_PASS}" \
  # --header "Authorization: Token ${INFLUX_TOKEN}" \


# echo "v2.0 requests";
# Check token auth
# curl -v --request GET \
#      "${INFLUX_URL}${v2}/dashboards/07a2173eeb45d000/owners${QUERY_PARAMS}" \
# 	--header "Authorization: Token ${INFLUX_TOKEN}" | python -m json.tool

# Create DBRP mapping for v1.x compat

  curl --request POST "${INFLUX_URL}${V2}/dbrps" \
   --header "Authorization: Token ${INFLUX_OP_TOKEN}" \
   --header 'Content-type: application/json' \
   --data '{
        "bucketID": "'"$INFLUX_BUCKET_ID"'",
        "database": "iot_center_db",
        "default": true,
        "orgID": "'"$INFLUX_ORG_ID"'",
        "retention_policy": "autogen"
      }'
