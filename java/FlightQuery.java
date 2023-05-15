package com.influxdb.examples;

import org.apache.arrow.flight.auth2.BearerCredentialWriter;
import org.apache.arrow.flight.CallHeaders;
import org.apache.arrow.flight.CallStatus;
import org.apache.arrow.flight.grpc.CredentialCallOption;
import org.apache.arrow.flight.Location;
import org.apache.arrow.flight.FlightClient;
import org.apache.arrow.flight.FlightClientMiddleware;
import org.apache.arrow.flight.FlightInfo;
import org.apache.arrow.flight.FlightStream;
import org.apache.arrow.flight.sql.FlightSqlClient;
import org.apache.arrow.flight.Ticket;
import org.apache.arrow.memory.BufferAllocator;
import org.apache.arrow.memory.RootAllocator;
import org.apache.arrow.vector.VectorSchemaRoot;

public class FlightQuery {
    public static final String DATABASE_NAME = System.getenv("CLOUD_SERVERLESS_BUCKET_NAME");
    public static final String DATABASE_HOST = System.getenv("CLOUD_SERVERLESS_HOST");
    public static final String DATABASE_TOKEN = System.getenv("CLOUD_SERVERLESS_READ_TOKEN");

    public static void main() {
        String sql = """
            SELECT DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP) AS time,
              room,
              selector_max(temp, time)['value'] AS 'max temp',
              selector_min(temp, time)['value'] AS 'min temp',
              avg(temp) AS 'average temp'
            FROM home
            GROUP BY DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP),
              room
            ORDER BY room, time""";
        FlightClientMiddleware.Factory f = info -> new FlightClientMiddleware() {
            @Override
            public void onBeforeSendingHeaders(CallHeaders outgoingHeaders) {
                outgoingHeaders.insert("database", DATABASE_NAME);
            }

            @Override
            public void onHeadersReceived(CallHeaders incomingHeaders) {
            }

            @Override
            public void onCallCompleted(CallStatus status) {
            }
        };

        Location location = Location.forGrpcTls(DATABASE_HOST, 443);
        BufferAllocator allocator = new RootAllocator(Long.MAX_VALUE);
        FlightClient client = FlightClient.builder(allocator, location)
                .intercept(f)
                .build();
        FlightSqlClient sqlClient = new FlightSqlClient(client);

        CredentialCallOption auth = new CredentialCallOption(new BearerCredentialWriter(DATABASE_TOKEN));
        FlightInfo flightInfo = sqlClient.execute(sql, auth);
        Ticket ticket = flightInfo.getEndpoints().get(0).getTicket();
        final FlightStream stream = sqlClient.getStream(ticket, auth);

        while (stream.next()) {
            try {
                final VectorSchemaRoot root = stream.getRoot();
                System.out.println("Rows: " + root.getRowCount());
                // View and analyze Arrow vector data
                System.out.println(root.contentToTSVString());
            } catch (Exception e) {
                System.out.println("Error executing FlightSqlClient: " + e.getMessage());
            }
        }
        try {
            stream.close();
        } catch (Exception e) {
            System.out.println("Error closing stream: " + e.getMessage());
        }

        try {
            sqlClient.close();
        } catch (Exception e) {
            System.out.println("Error closing client: " + e.getMessage());
        }
    }
}