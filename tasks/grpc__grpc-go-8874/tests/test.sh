#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/transport"
cp "/tests/internal/transport/keepalive_test.go" "internal/transport/keepalive_test.go"
mkdir -p "internal/transport"
cp "/tests/internal/transport/transport_test.go" "internal/transport/transport_test.go"
mkdir -p "stats/opentelemetry"
cp "/tests/stats/opentelemetry/e2e_test.go" "stats/opentelemetry/e2e_test.go"

# Run the specific test packages (Go tests are run by package, not by file)
# The test files are in: internal/transport and stats/opentelemetry
go test -v -timeout 7m ./internal/transport ./stats/opentelemetry
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
