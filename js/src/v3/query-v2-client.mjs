import {InfluxDB} from '@influxdata/influxdb-client';

const sql=`
  SELECT DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP) AS time,
    room,
    selector_max(temp, time)['value'] AS 'max temp',
    selector_min(temp, time)['value'] AS 'min temp',
    avg(temp) AS 'average temp'
  FROM home
  GROUP BY DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP),
    room
  ORDER BY room, time`;

const fluxQuery = `
  import "experimental/iox"
  iox.sql(
    bucket: "${process.env.CLOUD_SERVERLESS_BUCKET_NAME}",
    query: "${sql}"
  )
`;

const queryApi = new InfluxDB({url: process.env.CLOUD_SERVERLESS_URL,
                            token: process.env.CLOUD_SERVERLESS_READ_TOKEN})
                .getQueryApi(process.env.CLOUD_SERVERLESS_ORG);

console.log('*** QueryRows ***');
queryApi.queryRows(fluxQuery, {
  next: (row, tableMeta) => {
    // From each row, create an object with column names as keys
    const o = tableMeta.toObject(row)
    console.log(
      `${o.time} in '${o.room}': max: ${o['max temp']}, min: ${o['min temp']}, avg: ${o['average temp']}`
    )
  },
  error: (error) => {
    console.error(error)
    console.log('\nQueryRows ERROR')
  },
  complete: () => {
    console.log('\nQueryRows SUCCESS')
  },
});
