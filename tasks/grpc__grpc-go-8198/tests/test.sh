#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "credentials/google"
cp "/tests/credentials/google/google_test.go" "credentials/google/google_test.go"
mkdir -p "credentials/sts"
cp "/tests/credentials/sts/sts_test.go" "credentials/sts/sts_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./credentials/google/... ./credentials/sts/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
