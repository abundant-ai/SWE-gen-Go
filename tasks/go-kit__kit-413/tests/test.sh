#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "sd/etcd"
cp "/tests/sd/etcd/registrar_test.go" "sd/etcd/registrar_test.go"

# Run tests for the specific package containing the modified test files
go test -v ./sd/etcd 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
