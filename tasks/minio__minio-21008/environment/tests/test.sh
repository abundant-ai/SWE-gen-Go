#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/event/target"
cp "/tests/internal/event/target/nats_tls_contrib_test.go" "internal/event/target/nats_tls_contrib_test.go"

# Run tests from the modified test file
go test -v ./internal/event/target -run "^TestNatsConnTLSCustomCA$|^TestNatsConnTLSCustomCAHandshakeFirst$|^TestNatsConnTLSClientAuthorization$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
