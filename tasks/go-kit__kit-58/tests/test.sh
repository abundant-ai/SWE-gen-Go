#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "circuitbreaker"
cp "/tests/circuitbreaker/gobreaker_test.go" "circuitbreaker/gobreaker_test.go"
mkdir -p "circuitbreaker"
cp "/tests/circuitbreaker/handy_breaker_test.go" "circuitbreaker/handy_breaker_test.go"
mkdir -p "circuitbreaker"
cp "/tests/circuitbreaker/hystrix_test.go" "circuitbreaker/hystrix_test.go"
mkdir -p "circuitbreaker"
cp "/tests/circuitbreaker/util_test.go" "circuitbreaker/util_test.go"

# Run the specific tests for the circuitbreaker package
go test -v ./circuitbreaker 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
