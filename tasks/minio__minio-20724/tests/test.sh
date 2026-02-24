#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/admin-handlers-users_test.go" "cmd/admin-handlers-users_test.go"

# Run tests from the modified test file
go test -v ./cmd -run "^TestIAMInternalIDPServerSuite$|^TestIAM_AMPInternalIDPServerSuite$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
