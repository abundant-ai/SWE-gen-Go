#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "exp/api/remote"
cp "/tests/exp/api/remote/remote_api_test.go" "exp/api/remote/remote_api_test.go"

# Run tests for the specific package
cd exp
go test -v ./api/remote
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
