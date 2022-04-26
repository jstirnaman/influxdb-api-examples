import https from 'https';
import querystring from 'querystring';

const INFLUX = process.env;

export function Query() {
    const params = {
      db: influxDB,
      q: 'SELECT * FROM node_cpu_usage',
    }

    const qs = querystring.stringify(params);

    const options = {
      host: influxHostname,
      path: `/query?${qs}`,
      headers: {
        'Authorization': `Token ${INFLUX.INFLUX_TOKEN}`,
        'Content-type': 'application/json'
      },
    };

    const request = https.get(options, (response) => {
      let rawData = '';

      response.on('data', (chunk) => { rawData += chunk; });
      /*
      response.on('end', () => {
        try {
          const parsedData = JSON.parse(rawData);
          console.log(parsedData);
          const results = Array.isArray(parsedData?.results) && parsedData.results;
          console.log(results[0]?.series[0]);
        } catch (e) {
          console.error(`Error: ${e.message}`);
        }
      });
      */

      /*
      response.on('end', () => {
        try {
          console.log(JSON.parse(rawData));
        } catch(e) {
          console.error(`Error: ${e.message}`);
        }
      })
     */

    }).on('error', (e) => {
      console.error(`Request error: ${e.code} ${e.message}`);
    });

     /* .write only if POSTing data */
    // request.write(qs)

    request.end();

    /* .once only if POSTing data */
    // request.once('response', (res) => {
    //   console.log(res.status);
    //   console.log(`${res.data}`);
    // })
  }
