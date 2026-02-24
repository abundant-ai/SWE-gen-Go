#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/backend/remote-state/s3"
cp "/tests/internal/backend/remote-state/s3/backend_test.go" "internal/backend/remote-state/s3/backend_test.go"

# Run tests for the s3 backend (it's a separate Go module)
cd internal/backend/remote-state/s3
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
