#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/rpc_util_test.go" "rpc_util_test.go"
mkdir -p "test"
cp "/tests/compressor_test.go" "test/compressor_test.go"

# Run the specific test packages for this PR
# Test files: rpc_util_test.go (root package), test/compressor_test.go (test package)
go test -v -timeout 7m . ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
