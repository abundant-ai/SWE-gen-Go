#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/api-response_test.go" "cmd/api-response_test.go"

# Run ONLY the specific test files from the PR
go test -v -tags kqueue,dev ./cmd -run "TestObjectLocation|TestGetURLScheme|TestTrackingResponseWriter|TestHeadersAlreadyWritten|TestHeadersAlreadyWrittenWrapped|TestWriteResponseHeadersNotWritten|TestWriteResponseHeadersWritten"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
