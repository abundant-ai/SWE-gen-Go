#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "exp/api/remote"
cp "/tests/exp/api/remote/remote_api_test.go" "exp/api/remote/remote_api_test.go"
mkdir -p "exp/api/remote"
cp "/tests/exp/api/remote/remote_headers_test.go" "exp/api/remote/remote_headers_test.go"

# Run only the specific test files for this PR
# exp is a separate Go module, so we need to cd into it first
cd exp
go test -v ./api/remote
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
