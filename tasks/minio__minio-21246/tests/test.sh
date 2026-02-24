#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/object-api-listobjects_test.go" "cmd/object-api-listobjects_test.go"

# Run tests from the modified test file
# Note: TestListObjectsWithILM is excluded because it requires ILM infrastructure initialization
# that causes panics in the test environment, affecting both BASE and HEAD states
go test -v -tags kqueue,dev ./cmd -run "^TestListObjects$|^TestListObjectsVersionedFolders$|^TestListObjectsOnVersionedBuckets$|^TestListObjectVersions$|^TestListObjectsContinuation$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
