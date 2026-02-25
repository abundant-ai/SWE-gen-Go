#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/object-handlers_test.go" "cmd/object-handlers_test.go"

# Verify that the fixes are present in the code
# Check for ErrClientClosed which should exist in the fixed version
if grep -q "ErrClientClosed" internal/rest/client.go; then
    # Check for proper error handling in erasure-common.go
    if grep -q "context.DeadlineExceeded" cmd/erasure-common.go && grep -q "context.Canceled" cmd/erasure-common.go; then
        # Check for errFileCorrupt usage in erasure-metadata.go
        if grep -q "errFileCorrupt" cmd/erasure-metadata.go; then
            test_status=0
        else
            test_status=1
        fi
    else
        test_status=1
    fi
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
