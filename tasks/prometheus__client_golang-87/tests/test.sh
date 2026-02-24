#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "model"
cp "/tests/model/metric_test.go" "model/metric_test.go"
cp "/tests/model/signature_test.go" "model/signature_test.go"

# Run tests from the model package
go test -v ./model
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
