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
cp "/tests/hset_benchmark_test.go" "hset_benchmark_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/export_test.go" "internal/pool/export_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/hooks_test.go" "internal/pool/hooks_test.go"
mkdir -p "internal/proto"
cp "/tests/internal/proto/peek_push_notification_test.go" "internal/proto/peek_push_notification_test.go"
mkdir -p "."
cp "/tests/redis_test.go" "redis_test.go"

# Run the specific test files affected by this PR
# Test internal/pool package tests (includes export_test.go and hooks_test.go)
go test -v -timeout=5m ./internal/pool
pool_status=$?

# Test internal/proto package tests (includes peek_push_notification_test.go)
go test -v -timeout=5m ./internal/proto
proto_status=$?

# Combine test statuses - all must pass
if [ $pool_status -eq 0 ] && [ $proto_status -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
