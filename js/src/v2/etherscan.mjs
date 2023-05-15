import got from 'got';
import querystring from 'querystring';

async function tokenSupply({url, contractaddress, apikey}) {
    const searchParams = {
      module: 'stats',
      action: 'tokensupply',
      contractaddress,
      apikey
    };

    const options = {
      prefixUrl: url,
      headers: {
        'Content-Type': 'application/json'
      },
      searchParams
    };

    const {headers, body} = await got.get('', options);

    const data = {...JSON.parse(body), ...searchParams};
    delete data.apikey
    data.url = url;
    data.timestamp = getTimestamp(headers?.date);
    return data;
}

async function circulatingSupply({url, contractaddress, apikey}) {
    const searchParams = {
            module: 'stats',
            action: 'tokenCsupply',
            contractaddress,
            apikey
          };

    const options = {
      prefixUrl: url,
      headers: {
        'Content-Type': 'application/json'
      },
      searchParams
    };

    const {headers, body} = await got.get('', options);

    const data = {...JSON.parse(body), ...searchParams};
    delete data.apikey
    data.url = url;
    data.timestamp = getTimestamp(headers?.date);
    return data;
}

async function tokenBalance({url, address, contractaddress, apikey, tag}) {
    const searchParams = {
      module: 'account',
      action: 'tokenbalance',
      contractaddress,
      address,
      tag: tag ||= 'latest',
      apikey
    };

    const options = {
      prefixUrl: url,
      headers: {
        'Content-Type': 'application/json'
      },
      searchParams
    };

    const {headers, body} = await got.get('', options);

    const data = {...JSON.parse(body), ...searchParams};
    delete data.apikey
    data.url = url;
    data.timestamp = getTimestamp(headers?.date);
    return data;
}

function getTimestamp(date) {
  return Date.parse(date || Date.now());
}

function lineprotocol(data) {
  return `${data.action},module=${data.module},url=${data.url},contractaddress=${data.contractaddress},address=${data.address},tag=${data.tag},status=${data.status} result=${data.result} ${data.timestamp}`
}

export default {
  tokenSupply,
  circulatingSupply,
  tokenBalance,
  lineprotocol
}
