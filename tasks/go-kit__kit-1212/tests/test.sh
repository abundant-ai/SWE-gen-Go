#!/bin/bash

cd /app/src

# Set GOFLAGS to match CI environment
export GOFLAGS="-mod=readonly"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "transport/http"
cp "/tests/transport/http/intercepting_writer_test.go" "transport/http/intercepting_writer_test.go"

# Run the specific test file for this PR
go test -v ./transport/http -run "TestInterceptingWriter"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
