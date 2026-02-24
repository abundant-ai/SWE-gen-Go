#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "helper"
cp "/tests/helper/helper_test.go" "helper/helper_test.go"
mkdir -p "."
cp "/tests/hotkeys_commands_test.go" "hotkeys_commands_test.go"

# Start Redis server in background on port 6379
redis-server --daemonize yes --port 6379 --save "" --appendonly no

# Wait for Redis to be ready
sleep 2
redis-cli ping || sleep 3

# Run the specific test files
# Run helper tests (unit tests, don't need Redis)
go test -v ./helper -run TestDigest
test_status=$?

# Try to compile the main package to verify hotkeys implementation exists
# In buggy state (NOP), this will fail because hotkeys_commands.go is deleted
# In fixed state (Oracle), this will succeed
go test -c -o /tmp/test_binary . 2>/dev/null
if [ $? -ne 0 ]; then
  # Compilation failed - this is expected in buggy state
  test_status=1
fi

# Stop Redis server
redis-cli shutdown || true

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
