#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/cache_internal_test.go" "loadbalancer/cache_internal_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/dns_srv_publisher_internal_test.go" "loadbalancer/dns_srv_publisher_internal_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/random_test.go" "loadbalancer/random_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/retry_test.go" "loadbalancer/retry_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/round_robin_test.go" "loadbalancer/round_robin_test.go"
mkdir -p "loadbalancer"
cp "/tests/loadbalancer/static_publisher_test.go" "loadbalancer/static_publisher_test.go"

# Run the specific tests for the loadbalancer package
go test -v ./loadbalancer 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
