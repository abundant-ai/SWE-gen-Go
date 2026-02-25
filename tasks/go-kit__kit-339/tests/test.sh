#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Run the specific tests for the tracing/opentracing package
go test -v ./tracing/opentracing -run "Test" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
