#!/bin/bash

cd /app/src

# Start PostgreSQL
service postgresql start

# Set environment variables for PostgreSQL connection
export PGX_TEST_DATABASE="host=127.0.0.1 user=root password=secret dbname=pgx_test"
export PGX_TEST_UNIX_SOCKET_CONN_STRING="host=/var/run/postgresql dbname=pgx_test"
export PGX_TEST_TCP_CONN_STRING="host=127.0.0.1 user=root password=secret dbname=pgx_test"
export PGX_TEST_SCRAM_PASSWORD_CONN_STRING="host=127.0.0.1 user=pgx_scram password=secret dbname=pgx_test"
export PGX_TEST_MD5_PASSWORD_CONN_STRING="host=127.0.0.1 user=root password=secret dbname=pgx_test"
export PGX_TEST_PLAIN_PASSWORD_CONN_STRING="host=127.0.0.1 user=pgx_pw password=secret dbname=pgx_test"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/batch_test.go" "batch_test.go"
mkdir -p "."
cp "/tests/bench_test.go" "bench_test.go"
mkdir -p "pgconn"
cp "/tests/pgconn/pgconn_test.go" "pgconn/pgconn_test.go"
mkdir -p "."
cp "/tests/query_test.go" "query_test.go"

# Run tests from the specific test files touched by this PR
# Tests from batch_test.go, bench_test.go, query_test.go (in main package)
go test -v -run="TestConnSendBatch|TestConnQueryScan|TestConnQueryRowsFieldDescriptionsBeforeNext|TestConnQueryWithoutResultSetCommandTag|TestConnQueryScanWithManyColumns|TestBench" .
main_tests=$?

# Tests from pgconn/pgconn_test.go
cd pgconn
go test -v .
pgconn_tests=$?
cd ..

# Check if any tests failed
if [ $main_tests -eq 0 ] && [ $pgconn_tests -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
