#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Clean up any problematic tool files in dependencies
find /go/src/golang.org/x/sys/unix -name "mk*.go" -delete 2>/dev/null || true

# Copy HEAD files from /tests (overwrites BASE state)
cp "/tests/alt_exit.go" "alt_exit.go"
cp "/tests/alt_exit_test.go" "alt_exit_test.go"

# This PR adds the alt_exit functionality and tests
# Run only the alt_exit tests (both TestRegister and TestHandler)
go test -v -run "TestRegister|TestHandler" . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
