#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/process_collector_windows_test.go" "prometheus/process_collector_windows_test.go"

# Verify that the Windows implementation file exists (created by fix.patch)
if [ -f "prometheus/process_collector_windows.go" ]; then
    # Verify the package builds successfully for Windows
    GOOS=windows go test -c ./prometheus 2>&1
    test_status=$?
else
    # Windows implementation is missing - this is the buggy state
    echo "Windows implementation file missing" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
