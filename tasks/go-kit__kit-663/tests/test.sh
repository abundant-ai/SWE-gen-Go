#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "sd/etcdv3"
cp "/tests/sd/etcdv3/example_test.go" "sd/etcdv3/example_test.go"
mkdir -p "sd/etcdv3"
cp "/tests/sd/etcdv3/instancer_test.go" "sd/etcdv3/instancer_test.go"
mkdir -p "sd/etcdv3"
cp "/tests/sd/etcdv3/integration_test.go" "sd/etcdv3/integration_test.go"
mkdir -p "sd/etcdv3"
cp "/tests/sd/etcdv3/registrar_test.go" "sd/etcdv3/registrar_test.go"

# Run the tests for this PR
go test -v ./sd/etcdv3
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
