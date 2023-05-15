from influxdb import InfluxDBClient
import os

DATABASE_NAME = os.getenv('CLOUD_DEDICATED_DATABASE_NAME')
DATABASE_TOKEN = os.getenv('CLOUD_DEDICATED_DATABASE_TOKEN')
INFLUXDB_URL=os.getenv('CLOUD_DEDICATED_URL')
INFLUXDB_HOST=os.getenv('CLOUD_DEDICATED_HOST')
ORG=os.getenv('CLOUD_DEDICATED_ORG')

def influxdb_v1_client(headers=None):
  client = InfluxDBClient(
                        host=INFLUXDB_HOST,
                        port=443,
                        ssl=True,
                        database=DATABASE_NAME,
                        username='USERNAME',
                        password=DATABASE_TOKEN,
                        headers=headers
                        )
  print(vars(client))
  return client

def influxdb_v1_write():
  client = influxdb_v1_client(headers={'Content-Type': 'text/plain; charset=utf-8'})
  response = client.write(data="home,room=kitchen temp=72 1463683075", protocol='line')
  return response

def influxdb_v1_influxql():
  client = influxdb_v1_client()
  response = client.query('show measurements')
  print(response)
  return response

influxdb_v1_influxql()
