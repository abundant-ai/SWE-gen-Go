#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "sd/etcd"
cp "/tests/sd/etcd/client_test.go" "sd/etcd/client_test.go"
cp "/tests/sd/etcd/instancer_test.go" "sd/etcd/instancer_test.go"

# Run the tests for this PR
go test -v ./sd/etcd
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
