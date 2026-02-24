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
cp "/tests/acl_commands_test.go" "acl_commands_test.go"
mkdir -p "."
cp "/tests/error_test.go" "error_test.go"
mkdir -p "."
cp "/tests/error_wrapping_test.go" "error_wrapping_test.go"
mkdir -p "internal/proto"
cp "/tests/internal/proto/redis_errors_test.go" "internal/proto/redis_errors_test.go"
mkdir -p "push"
cp "/tests/push/processor_unit_test.go" "push/processor_unit_test.go"

# Run the specific test files for this PR
# Test files: acl_commands_test.go, error_test.go, error_wrapping_test.go in root
# internal/proto/redis_errors_test.go, push/processor_unit_test.go in subdirs
go test -v -timeout=5m \
  -run='TestACL|TestError|TestErrorWrapping' . \
  ./internal/proto/... \
  ./push/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
