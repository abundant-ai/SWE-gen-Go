#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/hscan"
cp "/tests/internal/hscan/hscan_test.go" "internal/hscan/hscan_test.go"

# Run the specific test file for this PR
# The main functional bug fix is in internal/hscan/structmap.go which is tested by hscan_test.go
# (json_test.go only has whitespace changes and requires Redis with JSON module)
go test -v ./internal/hscan
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
