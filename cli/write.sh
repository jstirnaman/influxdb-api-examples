# setup: write line protocol from a file
influx write \                                                               
--bucket jason-iox-explicit \
-p s "$(cat /Users/ja/Documents/GitHub/influxdb-api-examples/data/home-sensor-data.lp)"

# IOx SQL query should return tabular data

influx query "
import \"experimental/iox\"

iox.sql(
    bucket: \"jason-iox-explicit\",
    query: \"
        SELECT
          *
        FROM
          home
        WHERE
          time >= '2023-03-06T08:00:00Z'
          AND time <= '2023-03-06T20:00:00Z'
    \",
)"