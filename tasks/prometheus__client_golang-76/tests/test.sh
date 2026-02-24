#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extraction"
cp "/tests/extraction/metricfamilyprocessor_test.go" "extraction/metricfamilyprocessor_test.go"
mkdir -p "text"
cp "/tests/text/create_test.go" "text/create_test.go"
cp "/tests/text/parse_test.go" "text/parse_test.go"

# Run tests for the extraction and text packages
go test -v github.com/prometheus/client_golang/extraction github.com/prometheus/client_golang/text
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
