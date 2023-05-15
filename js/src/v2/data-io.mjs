import got from 'got';
import querystring from 'querystring';

const INFLUX = process.env;

async function write({bucket, lineprotocol, precision}) {
    const searchParams = {
      bucket,
      orgID: INFLUX.INFLUX_ORG,
      precision: precision || 'ms'
    }
    const options = {
      prefixUrl: INFLUX.INFLUX_URL,
      headers: {
        Authorization: `Token ${INFLUX.INFLUX_READ_WRITE_TOKEN}`,
        'Content-Type': 'text/plain; charset=utf-8',
        Accept: 'application/json'
      },
      searchParams,
      body: lineprotocol
    };

    const {headers, body} = await got.post(`api/v2/write`, options);
    return {headers, body};
}

async function deletePoints({bucket, predicate, start, stop}) {
    const searchParams = {
      bucket,
      orgID: INFLUX.INFLUX_ORG,
    }
    const options = {
      prefixUrl: INFLUX.INFLUX_URL,
      headers: {
        Authorization: `Token ${INFLUX.INFLUX_READ_WRITE_TOKEN}`,
        'Content-Type': 'application/json',
        Accept: 'application/json'
      },
      searchParams,
      json: {
        predicate,
        start,
        stop
      }
    };

    const {headers, body} = await got.post(`api/v2/delete`, options);
    return {headers, body};
}

export default {
  deletePoints,
  write
}
