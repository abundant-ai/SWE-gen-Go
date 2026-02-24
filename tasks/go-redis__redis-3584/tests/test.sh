#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Start Redis server in the background
redis-server --daemonize yes --port 6379

# Wait for Redis to be ready
timeout 10s bash -c 'until redis-cli ping; do sleep 0.1; done' 2>/dev/null || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/commands_test.go" "commands_test.go"

# Run the specific test file for this PR
go test -v -timeout=5m -run='TestCommand' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
