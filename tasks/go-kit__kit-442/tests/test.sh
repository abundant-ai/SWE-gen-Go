#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
# No test files to copy

# Check if Circonus package exists - it should be removed at HEAD (fixed state)
# Note: Check for the .go file, not just the directory (patch might leave empty directory)
if [ -f "metrics/circonus/circonus.go" ]; then
    # Circonus exists (BASE state with bug) - tests should fail
    echo "ERROR: Circonus package still exists - this is the buggy state" >&2
    test_status=1
else
    # Circonus doesn't exist (HEAD state with fix) - run metrics tests to verify
    go test -v ./metrics/generic ./metrics/multi ./metrics/internal/lv 2>&1
    test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
