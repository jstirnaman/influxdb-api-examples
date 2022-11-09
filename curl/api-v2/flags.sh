function getFlags() {

  # Should return authorized flags for a token.
  curl -v "${INFLUX_URL}/api/v2/flags" \
   --header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .

  # Should return authorized flags for a user session.
  # curl -v "${INFLUX_URL}/api/v2/flags" \
  # --header "Authorization: Token ${INFLUX_API_TOKEN}" | jq .

  # Should return preauth/public flags.
  curl -v "${INFLUX_URL}/api/v2/flags" | jq .
}

getFlags