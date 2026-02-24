#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/gooseutil"
cp "/tests/internal/gooseutil/resolve_test.go" "internal/gooseutil/resolve_test.go"
mkdir -p "."
cp "/tests/provider_collect_test.go" "provider_collect_test.go"
mkdir -p "."
cp "/tests/provider_run_test.go" "provider_run_test.go"

# Run the specific test files from the PR
go test -v ./internal/gooseutil -run TestResolve && \
go test -v . -run TestProviderCollect && \
go test -v . -run TestProviderRun
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
