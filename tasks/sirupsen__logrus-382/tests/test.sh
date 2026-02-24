#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Clean up any problematic tool files in dependencies
find /go/src/golang.org/x/sys/unix -name "mk*.go" -delete 2>/dev/null || true

# This PR removes the logstash formatter package
# Verify that formatters/logstash directory does not exist
if [ -d "formatters/logstash" ]; then
  echo "ERROR: formatters/logstash package still exists (should be removed)" >&2
  test_status=1
else
  go test -v . 2>&1
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
