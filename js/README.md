# README

## Description

This project provides a simple example of using a Node.js REST client to collect on-chain data from Etherscan and Polygonscan and then write the data to InfluxDB.
These modules are intended only for testing InfluxDB API methods.
If you want to use the InfluxDB API in a real application,
you should consider the [InfluxDB client libraries](https://docs.influxdata.com/influxdb/cloud/api-guide/client-libraries/) which provide production-ready
features like batch writes, retries, data processing, and error handling.

## How to run the JavaScript modules

1. In the repo home directory, set your environment variables in `../.env.cloud` or `../.env.oss`.
2. Run `npm run start:cloud` or `npm run start:oss` to test your settings.