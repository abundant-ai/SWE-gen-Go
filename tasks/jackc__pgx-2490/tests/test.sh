#!/bin/bash

cd /app/src

# Start PostgreSQL
service postgresql start

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/batch_test.go" "batch_test.go"

# Set environment variables for PostgreSQL connection
export PGX_TEST_DATABASE="host=127.0.0.1 user=root password=secret dbname=pgx_test"
export PGX_TEST_UNIX_SOCKET_CONN_STRING="host=/var/run/postgresql dbname=pgx_test"
export PGX_TEST_TCP_CONN_STRING="host=127.0.0.1 user=root password=secret dbname=pgx_test"
export PGX_TEST_SCRAM_PASSWORD_CONN_STRING="host=127.0.0.1 user=pgx_scram password=secret dbname=pgx_test"
export PGX_TEST_MD5_PASSWORD_CONN_STRING="host=127.0.0.1 user=root password=secret dbname=pgx_test"
export PGX_TEST_PLAIN_PASSWORD_CONN_STRING="host=127.0.0.1 user=pgx_pw password=secret dbname=pgx_test"

# Run tests from batch_test.go
go test -v -run="TestConnSendBatch|TestConnSendBatchQueuedQuery|TestConnSendBatchMany|TestConnSendBatchReadResultsWhenNothingQueued|TestConnSendBatchReadMoreResultsThanQueriesSent|TestConnSendBatchWithPreparedStatement|TestConnSendBatchWithQueryRewriter|TestConnSendBatchWithPreparedStatementAndStatementCacheDisabled|TestConnSendBatchCloseRowsPartiallyRead|TestConnSendBatchQueryError|TestConnSendBatchQuerySyntaxError|TestConnSendBatchErrorReturnsErrPreprocessingBatch|TestConnSendBatchQueryRowInsert|TestConnSendBatchQueryPartialReadInsert|TestTxSendBatch|TestTxSendBatchRollback|TestSendBatchErrorWhileReadingResultsWithoutCallback|TestSendBatchErrorWhileReadingResultsWithExecWhereSomeRowsAreReturned|TestConnBeginBatchDeferredError|TestConnSendBatchNoStatementCache" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
