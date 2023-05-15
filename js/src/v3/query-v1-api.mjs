import got from 'got';

const influxql=`
  SELECT FIRST(temp) as first_temp
  FROM home 
  WHERE room = 'kitchen'
    AND time >= now() - 100d
    AND time <= now() - 10d
  GROUP BY time(6h)`;

const url = `${process.env['CLOUD_DEDICATED_URL']}/query`;
const options = {
  searchParams: {
    db: process.env['CLOUD_DEDICATED_DATABASE_NAME'],
    q: influxql
  },
  headers: {
    'Authorization': `Bearer ${process.env['CLOUD_DEDICATED_DATABASE_TOKEN']}`,
    'Accept': 'application/json'
  }
};

const {results} = await got.get(url, options).json();

const xLabel = results[0].series[0].columns[0]; // InfluxDB always returns a time column
const yLabel = results[0].series[0].columns[1];
const x = results[0].series[0].values.map(v => v[0]);
const y = results[0].series[0].values.map(v => v[1]);

console.log(xLabel, x.slice(0, 10), yLabel, y.slice(0, 10));
