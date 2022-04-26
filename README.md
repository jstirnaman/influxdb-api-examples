# README

## Description

This repository contains simple Curl scripts and JavaScript modules that
provide examples of InfluxDB API requests and features. 
These scripts are intended only to provide tests and examples for InfluxDB API methods.

If you want to use the InfluxDB API in a real application,
see the [InfluxDB client libraries](https://docs.influxdata.com/influxdb/cloud/api-guide/client-libraries/) that provide production-ready
features like batch writes, retries, data processing, and error handling.

## Set environment variables with a .env file

The Curl scripts in this repo assume you have `INFLUXDB_` environment variables
in the calling shell.
To set environment variables that will be shared by the Curl scripts
and the JavaScript modules, add the following files:

- `.env.oss`: for OSS environment variables
- `.env.cloud`: for Cloud environment variables

Use `default.env` as a starter template for these files.

The `.env.oss` and `.env.cloud` files should set environment variables, but not export them.
This keeps the configuration files usable as _dotenv_ files in NodeJS modules.
To export the variables to the context of the calling shell and make them available to shell (Curl) scripts, run one of the following commands:

## Export OSS environment variables

```sh
. ./oss.sh
```

## Export Cloud environment variables

```sh
. ./cloud.sh
```
