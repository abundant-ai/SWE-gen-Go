#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/commands_test.go" "commands_test.go"
mkdir -p "doctests"
cp "/tests/doctests/stream_tutorial_test.go" "doctests/stream_tutorial_test.go"
mkdir -p "."
cp "/tests/search_test.go" "search_test.go"

# The PR adds fields to XInfoStream/XInfoStreamFull and FTHybridVectorExpression structs.
# In the buggy state (NOP), compiling test files that reference these fields will fail.
# In the fixed state (Oracle), compilation will succeed.

# Try to compile the test files - this will fail in buggy state if tests reference the new fields
go test -c -o /tmp/test_main . 2>/dev/null
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
