#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/error_test.go" "error_test.go"
mkdir -p "."
cp "/tests/error_wrapping_test.go" "error_wrapping_test.go"
mkdir -p "internal/proto"
cp "/tests/internal/proto/redis_errors_test.go" "internal/proto/redis_errors_test.go"

# Run tests for specific test files
# For root package, run only the tests from error_wrapping_test.go (skip Ginkgo tests that need Redis server)
# For internal/proto package, run tests from redis_errors_test.go
go test -v -run "^Test(TypedErrorsWithHookWrapping|MovedAndAskErrorsWithHookWrapping|BackwardCompatibilityWithStringChecks|ErrorWrappingInHookScenario|ShouldRetryWithTypedErrors|SetErrWithWrappedError|CustomErrorTypeWrapping|TimeoutErrorWrapping|ContextErrorWrapping|IOErrorWrapping|PoolErrorWrapping|RedisErrorWrapping|AuthErrorWrapping|PermissionErrorWrapping|ExecAbortErrorWrapping|OOMErrorWrapping)$" . && go test -v ./internal/proto
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
