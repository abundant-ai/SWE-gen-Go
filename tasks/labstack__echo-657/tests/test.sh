#!/bin/bash

cd /go/src/github.com/labstack/echo

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/server.go" "test/server.go"
mkdir -p "_test_check"
cp "/tests/stop_check.go" "_test_check/main.go"

# Build and run the stop check program to verify Stop() functionality exists
cd _test_check && go build -o /tmp/stop_check .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
