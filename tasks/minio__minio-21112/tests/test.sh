#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/data-scanner_test.go" "cmd/data-scanner_test.go"
mkdir -p "internal/bucket/lifecycle"
cp "/tests/internal/bucket/lifecycle/evaluator_test.go" "internal/bucket/lifecycle/evaluator_test.go"

# Run tests from the modified test files
go test -v ./cmd -run "^Test(ApplyNewerNoncurrentVersionsLimit|EvalActionFromLifecycle)$" && \
go test -v ./internal/bucket/lifecycle -run "^Test(NewerNoncurrentVersions|EmptyEvaluator)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
