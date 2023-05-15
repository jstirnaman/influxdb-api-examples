from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from influxdb_client.client.exceptions import InfluxDBError
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

# v2
def influxdb_client():
  return InfluxDBClient(url=INFLUXDB_URL,
                        token=DATABASE_TOKEN,
                        org='foo',
                        debug=True)

def test_influx2_write():
  print('test_influx2')
  callback = BatchingCallback()
  with influxdb_client() as client:
      """
      Use batching API
      """
      with client.write_api(success_callback=callback.success,
                            error_callback=callback.error,
                            retry_callback=callback.retry) as write_api:
          write_api.write(bucket=DATABASE_NAME, record=points, content_encoding="identity",
                                              content_type="text/plain; charset=utf-8",)
          print()
          print("Wait to finish ingesting...")
          print()
          write_api.close()
# test_influx2_write()
