#!/bin/bash

cd /app/src

# Delete conflicting renamed files from bug.patch that fix.patch doesn't remove
# bug.patch renamed go_collector_latest.go -> go_collector_go117.go
# fix.patch creates new go_collector_latest.go but doesn't delete go_collector_go117.go
# This causes "redeclared in this block" errors
rm -f prometheus/go_collector_go117.go prometheus/go_collector_go117_test.go
rm -f prometheus/collectors/go_collector_go116.go

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_latest_test.go" "prometheus/go_collector_latest_test.go"

# Run the specific tests from the PR test files
go test -v ./prometheus -run "^(TestRmForMemStats|TestGoCollector|TestBatchHistogram|TestMemStatsEquivalence|TestExpectedRuntimeMetrics|TestGoCollectorConcurrency)$" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
