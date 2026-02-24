#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/vec_test.go" "prometheus/vec_test.go"

# Run only the specific tests from the PR test files
go test -v -run "^(TestDelete|TestDeleteWithCollisions|TestDeleteLabelValues|TestDeleteLabelValuesWithCollisions|TestMetricVec|TestMetricVecWithCollisions)$" ./prometheus
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
