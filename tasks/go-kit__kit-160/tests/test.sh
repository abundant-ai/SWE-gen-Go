#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "loadbalancer/zk"
cp "/tests/loadbalancer/zk/client_test.go" "loadbalancer/zk/client_test.go"
mkdir -p "loadbalancer/zk"
cp "/tests/loadbalancer/zk/integration_test.go" "loadbalancer/zk/integration_test.go"
mkdir -p "loadbalancer/zk"
cp "/tests/loadbalancer/zk/publisher_test.go" "loadbalancer/zk/publisher_test.go"

# Run the specific tests for the loadbalancer/zk package
go test -v ./loadbalancer/zk 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
