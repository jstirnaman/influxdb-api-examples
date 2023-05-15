from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from influxdb_client.client.exceptions import InfluxDBError
# from dedicated_query import *
import influxdb_client_3 as InfluxDBClient3
import os

DATABASE_NAME = os.getenv('CLOUD_DEDICATED_DATABASE_NAME')
DATABASE_TOKEN = os.getenv('CLOUD_DEDICATED_DATABASE_TOKEN')
INFLUXDB_URL=os.getenv('CLOUD_DEDICATED_URL')
INFLUXDB_HOST=os.getenv('CLOUD_DEDICATED_HOST')
ORG=os.getenv('CLOUD_DEDICATED_ORG')

points = [Point("home").tag("room", "kitchen").field("temp", 25.3),
          Point("home").tag("room", "living room").field("temp", 18.4)]

class BatchingCallback(object):

    def success(self, conf: (str, str, str), data: str):
        """Successfully writen batch."""
        print(f"Written batch: {conf}, data: {data}")

    def error(self, conf: (str, str, str), data: str, exception: InfluxDBError):
        """Unsuccessfully writen batch."""
        print(f"Cannot write batch: {conf}, data: {data} due: {exception}")

    def retry(self, conf: (str, str, str), data: str, exception: InfluxDBError):
        """Retryable error."""
        print(f"Retryable error occurs for batch: {conf}, data: {data} retry: {exception}")

def test_influx3_write_csv():
  print('test_influx3')
  client = InfluxDBClient3.InfluxDBClient3(token=DATABASE_TOKEN,
                         host=INFLUXDB_HOST,
                         database=DATABASE_NAME,
                         org='',
                         write_options="SYNCHRONOUS")
  
  client.write_csv('./data/example.csv', measurement_name='home', timestamp_column='Date')

# test_influx3_write_csv()

def test_influx3_write_lp():
  print('test_influx3_write_lp')
  client = InfluxDBClient3.InfluxDBClient3(token=DATABASE_TOKEN,
                         host=INFLUXDB_HOST,
                         database=DATABASE_NAME,
                         org='foo',
                         write_options="SYNCHRONOUS",
                         )
  
  client.write(database=DATABASE_NAME,
               record='home,room=1999partyroom temp=74 1682358981999')

test_influx3_write_lp()

def test_influx3_write_points():
  print('test_influx3_write_lp')
  client = InfluxDBClient3.InfluxDBClient3(token=DATABASE_TOKEN,
                         host=INFLUXDB_HOST,
                         database=DATABASE_NAME,
                         org='foo',
                         write_options="SYNCHRONOUS",
                         )
  
  client.write(database=DATABASE_NAME,
               record=points)
 
def test_influx3_query():
  print('test_influx3_query')
  client = InfluxDBClient3.InfluxDBClient3(token=DATABASE_TOKEN,
                        host=INFLUXDB_HOST,
                        database=DATABASE_NAME,
                        org='foo',
                        write_options="SYNCHRONOUS")
  print(vars(client))
  client.query(sql_query='select * from home')
  
test_influx3_query()