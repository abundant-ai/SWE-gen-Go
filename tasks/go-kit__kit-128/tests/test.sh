#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "loadbalancer/dnssrv"
cp "/tests/loadbalancer/dnssrv/publisher_internal_test.go" "loadbalancer/dnssrv/publisher_internal_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/endpoint_cache_test.go" "loadbalancer/endpoint_cache_test.go"
mkdir -p "loadbalancer/etcd"
cp "/tests/loadbalancer/etcd/publisher_test.go" "loadbalancer/etcd/publisher_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/random_test.go" "loadbalancer/random_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/round_robin_test.go" "loadbalancer/round_robin_test.go"
mkdir -p "loadbalancer/static"
cp "/tests/loadbalancer/static/publisher_test.go" "loadbalancer/static/publisher_test.go"

# Run the specific tests for the loadbalancer packages
go test -v ./loadbalancer/dnssrv ./loadbalancer/etcd ./loadbalancer/static ./loadbalancer 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
