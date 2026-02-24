#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# No test files to copy - this PR removes the airbrake hook

# This PR removes the built-in Airbrake hook from logrus
# Verify that hooks/airbrake/airbrake.go no longer exists
if [ -f "./hooks/airbrake/airbrake.go" ]; then
  echo "FAIL: hooks/airbrake/airbrake.go should not exist after fix" >&2
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Verify the main package still compiles
go build . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
