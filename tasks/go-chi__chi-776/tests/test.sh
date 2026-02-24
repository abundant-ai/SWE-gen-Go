#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/mux_test.go" "mux_test.go"

# Run tests from the mux_test.go file
go test -v -run "TestMux|TestMethod|TestRouter|TestSingle|TestServe|TestNested|TestMiddleware"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
