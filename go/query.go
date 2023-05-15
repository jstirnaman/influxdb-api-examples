package main

import (
	"context"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"os"

	"github.com/apache/arrow/go/v12/arrow/flight/flightsql"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"
)

func dbQuery(ctx context.Context) error {
	url := os.Getenv("CLOUD_SERVERLESS_HOST")+ ":443"
	token := os.Getenv("CLOUD_SERVERLESS_READ_TOKEN")
	database := os.Getenv("CLOUD_SERVERLESS_BUCKET_NAME")
	org_id := ""

	// Create a gRPC transport
	pool, err := x509.SystemCertPool()
	if err != nil {
		return fmt.Errorf("x509: %s", err)
	}
	transport := grpc.WithTransportCredentials(credentials.NewClientTLSFromCert(pool, org_id))
	opts := []grpc.DialOption{
		transport,
	}

	// Create query client
	client, err := flightsql.NewClient(url, nil, nil, opts...)
	if err != nil {
		return fmt.Errorf("flightsql: %s", err)
	}

	ctx = metadata.AppendToOutgoingContext(ctx, "authorization", "Token "+token)
	ctx = metadata.AppendToOutgoingContext(ctx, "database", database)

	// Execute query
	query := `SELECT DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP) AS time,
							room,
							selector_max(temp, time)['value'] AS 'max temp',
							selector_min(temp, time)['value'] AS 'min temp',
							avg(temp) AS 'average temp'
						FROM home
						GROUP BY DATE_BIN(INTERVAL '2 hours', time, '1970-01-01T00:00:00Z'::TIMESTAMP),
							room
						ORDER BY room, time`

	info, err := client.Execute(ctx, query)
	if err != nil {
		return fmt.Errorf("flightsql flight info: %s", err)
	}
	reader, err := client.DoGet(ctx, info.Endpoint[0].Ticket)
	if err != nil {
		return fmt.Errorf("flightsql do get: %s", err)
	}

	// Print results as JSON
	for reader.Next() {
		record := reader.Record()
		b, err := json.MarshalIndent(record, "", "  ")
		if err != nil {
			return err
		}
		fmt.Println("RECORD BATCH")
		fmt.Println(string(b))

		if err := reader.Err(); err != nil {
			return fmt.Errorf("flightsql reader: %s", err)
		}
	}

	return nil
}

func main() {
	if err := dbQuery(context.Background()); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}