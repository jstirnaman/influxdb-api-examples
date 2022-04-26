import got from 'got';
import querystring from 'querystring';

const INFLUX = process.env;

async function create() {
    const options = {
      prefixUrl: INFLUX.INFLUX_URL,
      headers: {
        'Authorization': `Token ${INFLUX.INFLUX_OP_TOKEN}`,
        'Content-type': 'application/json'
      },
      json: {
                description: `read-write-${Date.now()}`,
                orgID: INFLUX.INFLUX_ORG,
                permissions: [{action: 'read', resource: {type: 'buckets'}}, {action: 'write', resource: {type: 'buckets' }}],
                status: 'active'
              }
    };

    const {data} = await got.post(`api/v2/authorizations`, options).json();

    console.log(data);
}

export default {
  create
}
