from pyarrow.flight import FlightClient, Ticket, FlightCallOptions # Using pyarrow>=12.0.0 FlightClient
import json
import pandas
import tabulate
import os

DATABASE_NAME = os.getenv('CLOUD_DEDICATED_DATABASE_NAME')
DATABASE_TOKEN = os.getenv('CLOUD_DEDICATED_DATABASE_TOKEN')
DATABASE_HOST=os.getenv('CLOUD_DEDICATED_HOST')

influxql="""
  SELECT FIRST(temp)
  FROM home 
  WHERE room = 'kitchen'
    AND time >= now() - 100d
    AND time <= now() - 10d
  GROUP BY time(6h)"""
  
flight_ticket = Ticket(json.dumps({
  "namespace_name": DATABASE_NAME,
  "sql_query": influxql,
  "query_type": "influxql"
}))

token = (b"authorization", bytes(f"Bearer {DATABASE_TOKEN}".encode('utf-8')))
options = FlightCallOptions(headers=[token])
client = FlightClient(f"grpc+tls://{DATABASE_HOST}:443")

reader = client.do_get(flight_ticket, options)
arrow_table = reader.read_all()
# Use pyarrow and pandas to view and analyze data
data_frame = arrow_table.to_pandas()
print(data_frame.to_markdown())
