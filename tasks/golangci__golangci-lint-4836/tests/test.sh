#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/golinters/govet"
cp "/tests/pkg/golinters/govet/govet_test.go" "pkg/golinters/govet/govet_test.go"
mkdir -p "test"
cp "/tests/run_test.go" "test/run_test.go"
mkdir -p "test/testshared/integration"
cp "/tests/testshared/integration/run.go" "test/testshared/integration/run.go"

# Run the specific tests for this PR
go test -v ./pkg/golinters/govet/... ./test/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
