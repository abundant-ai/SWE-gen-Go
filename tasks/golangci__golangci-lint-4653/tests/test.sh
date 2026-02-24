#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/lint/lintersdb"
cp "/tests/pkg/lint/lintersdb/manager_test.go" "pkg/lint/lintersdb/manager_test.go"
mkdir -p "test"
cp "/tests/enabled_linters_test.go" "test/enabled_linters_test.go"

# Run the specific tests from the test files for this PR
go test -v ./pkg/lint/lintersdb/... -run="TestManager_GetEnabledLintersMap|TestManager_GetOptimizedLinters|TestManager_build|TestManager_combineGoAnalysisLinters" && \
go test -v ./test/... -run="TestEnabledLinters"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
