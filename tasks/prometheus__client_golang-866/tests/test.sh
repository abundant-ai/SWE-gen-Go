#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/dbstats_collector_test.go" "prometheus/collectors/dbstats_collector_test.go"

# Run only the specific test from the PR test file
go test -v -run '^TestDBStatsCollector$' ./prometheus/collectors 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
