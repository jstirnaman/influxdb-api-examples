import 'dotenv/config'
import { URL } from 'url'
import { Query } from './v1-query.mjs'
import Authorization from './authorization.mjs'
import Bucket from './bucket.mjs'
import Etherscan from './etherscan.mjs'
import DataIO from './data-io.mjs'


const ts = Etherscan.lineprotocol(await Etherscan.tokenSupply({
  url: 'https://api.polygonscan.com/api',
  apikey: process.env.POLYGONSCAN_API_KEY,
  contractaddress: '0x2f800db0fdb5223b3c3f354886d907a671414a7f'
}))

const cs = Etherscan.lineprotocol(await Etherscan.circulatingSupply({
  url: 'https://api.polygonscan.com/api',
  apikey: process.env.POLYGONSCAN_API_KEY,
  contractaddress: '0x2f800db0fdb5223b3c3f354886d907a671414a7f'
}))

const tb = Etherscan.lineprotocol(await Etherscan.tokenBalance({
  url: 'https://api.polygonscan.com/api',
  apikey: process.env.POLYGONSCAN_API_KEY,
  contractaddress: '0x2f800db0fdb5223b3c3f354886d907a671414a7f',
  address: '0x7dd4f0b986f032a44f913bf92c9e8b7c17d77ad7'
}))

const bucket = 'ethscanPrice';
const writeTs = await DataIO.write({bucket, lineprotocol: ts, precision: 'ms'});
const writeCs = await DataIO.write({bucket, lineprotocol: cs, precision: 'ms'});
const writeTb = await DataIO.write({bucket, lineprotocol: tb, precision: 'ms'});

  await DataIO.deletePoints({
    bucket,
    predicate: "module=\"account\"",
    start: "2022-01-01T14:15:22Z",
    stop: "2022-01-24T14:15:22Z"
  })

// console.log(writeTs);
// console.log(writeCs);
// console.log(writeTb);

// Authorization.create();
//Bucket.create({ name: `ethscanPrice`,
//                description: `Stores data from Etherscan` });
