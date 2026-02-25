#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/generic-handlers_test.go" "cmd/generic-handlers_test.go"
mkdir -p "cmd"
cp "/tests/cmd/lock-rest-client_test.go" "cmd/lock-rest-client_test.go"
mkdir -p "internal/grid"
cp "/tests/internal/grid/grid_test.go" "internal/grid/grid_test.go"

# Run specific tests from the modified test files
# From cmd/generic-handlers_test.go and cmd/lock-rest-client_test.go
go test -v -timeout 10m ./cmd -run "TestGuessIsRPC|TestIsHTTPHeaderSizeTooLarge|TestContainsReservedMetadata|TestSSETLSHandler|TestLockRESTlient"
cmd_status=$?

# From internal/grid/grid_test.go
go test -v -timeout 10m ./internal/grid -run "TestSingleRoundtrip|TestStreamSuite"
grid_status=$?

# Combine test statuses (fail if either failed)
if [ $cmd_status -eq 0 ] && [ $grid_status -eq 0 ]; then
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
