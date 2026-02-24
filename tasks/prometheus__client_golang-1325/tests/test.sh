#!/bin/bash

cd /app/src

# Run tests that check Go 1.21 specific runtime metrics support
# The Go 1.21 helper files should be present after fix is applied
go test -v ./prometheus/collectors -run "TestGoCollector" 2>&1 && \
go test -v ./prometheus -run "TestGoCollector|TestRmForMemStats" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
