from pyarrow.flight import FlightClient, Ticket, FlightCallOptions # Using pyarrow>=12.0.0 FlightClient
import json
import pandas
import tabulate
import os

DATABASE_NAME = os.getenv('CLOUD_SERVERLESS_BUCKET_NAME')
DATABASE_TOKEN = os.getenv('CLOUD_SERVERLESS_API_TOKEN')
DATABASE_HOST=os.getenv('CLOUD_SERVERLESS_HOST')

sql="""
  SELECT DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP) AS time,
    room,
    selector_max(temp, time)['value'] AS 'max temp',
    selector_min(temp, time)['value'] AS 'min temp',
    avg(temp) AS 'average temp'
  FROM home
  GROUP BY DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP),
    room
  ORDER BY room, time"""
  
flight_ticket = Ticket(json.dumps({
  "namespace_name": DATABASE_NAME,
  "sql_query": sql,
  "query_type": "sql"
}))

token = (b"authorization", bytes(f"Bearer {DATABASE_TOKEN}".encode('utf-8')))
options = FlightCallOptions(headers=[token])
client = FlightClient(f"grpc+tls://{DATABASE_HOST}:443")

reader = client.do_get(flight_ticket, options)
arrow_table = reader.read_all()
# Use pyarrow and pandas to view and analyze data
data_frame = arrow_table.to_pandas()
print(data_frame.to_markdown())
