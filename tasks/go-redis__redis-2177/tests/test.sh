#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/cluster_test.go" "cluster_test.go"
mkdir -p "."
cp "/tests/pubsub_test.go" "pubsub_test.go"

# Run the specific test files
go test -v -run="TestCluster|TestPubSub" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
