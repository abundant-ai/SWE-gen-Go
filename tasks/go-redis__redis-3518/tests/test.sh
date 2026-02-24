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
cp "/tests/async_handoff_integration_test.go" "async_handoff_integration_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/bench_test.go" "internal/pool/bench_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/buffer_size_test.go" "internal/pool/buffer_size_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/hooks_test.go" "internal/pool/hooks_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/want_conn_test.go" "internal/pool/want_conn_test.go"
mkdir -p "."
cp "/tests/options_test.go" "options_test.go"
mkdir -p "."
cp "/tests/pool_pubsub_bench_test.go" "pool_pubsub_bench_test.go"

# Run the specific test files affected by this PR
# Files: async_handoff_integration_test.go, options_test.go, pool_pubsub_bench_test.go (in root)
# Files: internal/pool/*_test.go (bench_test.go, buffer_size_test.go, hooks_test.go, pool_test.go, want_conn_test.go)
go test -v -timeout=5m \
  -run="^(TestAsyncHandoff|TestClusterClientOptionsFromURL|TestSingleClientOptionsFromURL|TestFailoverClientOptionsFromURL|TestSentinelClientOptionsFromURL|TestPubSubFlowControl)" \
  . ./internal/pool
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
