#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/command_digest_test.go" "command_digest_test.go"
mkdir -p "."
cp "/tests/digest_test.go" "digest_test.go"
mkdir -p "internal/auth/streaming"
cp "/tests/internal/auth/streaming/manager_test.go" "internal/auth/streaming/manager_test.go"
mkdir -p "internal/auth/streaming"
cp "/tests/internal/auth/streaming/pool_hook_state_test.go" "internal/auth/streaming/pool_hook_state_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/conn_relaxed_timeout_test.go" "internal/pool/conn_relaxed_timeout_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/conn_state_alloc_test.go" "internal/pool/conn_state_alloc_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/conn_state_test.go" "internal/pool/conn_state_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/double_freeturn_simple_test.go" "internal/pool/double_freeturn_simple_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/double_freeturn_test.go" "internal/pool/double_freeturn_test.go"
mkdir -p "internal/routing"
cp "/tests/internal/routing/aggregator_test.go" "internal/routing/aggregator_test.go"
mkdir -p "maintnotifications/e2e"
cp "/tests/maintnotifications/e2e/notiftracker_test.go" "maintnotifications/e2e/notiftracker_test.go"
mkdir -p "push"
cp "/tests/push/processor_unit_test.go" "push/processor_unit_test.go"

# Run tests for specific test files and sub-packages
# For root package, run only the specific test files to avoid running example tests that need Redis
go test -v -run "^(TestDigestCmd|TestDigestCmdResult)$" . && \
go test -v ./internal/auth/streaming/... ./internal/pool/... ./internal/routing/... ./maintnotifications/e2e/... ./push/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
