import got from 'got';
import querystring from 'querystring';

const INFLUX = process.env;

async function create({name, description, schemaType}) {
    const options = {
      prefixUrl: INFLUX.INFLUX_URL,
      headers: {
        'Authorization': `Token ${INFLUX.INFLUX_READ_WRITE_TOKEN}`,
        'Content-type': 'application/json'
      },
      json: {
                name: `ethscanPrice`,
                description: `Stores data from Etherscan`,
                orgID: INFLUX.INFLUX_ORG,
                schemaType
              }
    };

    const {data} = await got.post(`api/v2/buckets`, options).json();

    console.log(data);
}

export default {
  create
}
