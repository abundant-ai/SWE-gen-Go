#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
cp "/tests/go.mod" "tests/go.mod"
cp "/tests/query_test.go" "tests/query_test.go"

# Run the specific test (TestQueryResetNullValue from query_test.go)
cd /app/gorm/tests && go test -mod=mod -v -run '^TestQueryResetNullValue$'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
