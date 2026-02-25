#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "sd/etcd"
cp "/tests/sd/etcd/client_test.go" "sd/etcd/client_test.go"
cp "/tests/sd/etcd/example_test.go" "sd/etcd/example_test.go"
cp "/tests/sd/etcd/integration_test.go" "sd/etcd/integration_test.go"
cp "/tests/sd/etcd/subscriber_test.go" "sd/etcd/subscriber_test.go"

# Run the specific tests for the sd/etcd package
go test -v ./sd/etcd -run "Test" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
