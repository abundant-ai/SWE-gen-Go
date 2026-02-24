#!/bin/bash

cd /go/src/github.com/spf13/viper

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/viper_test.go" "viper_test.go"

# Get test dependencies and run tests
go get -t . 2>&1
go test -v . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
