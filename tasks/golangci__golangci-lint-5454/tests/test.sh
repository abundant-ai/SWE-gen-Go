#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/run_test.go" "test/run_test.go"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/default_exclude.yml" "test/testdata/configs/default_exclude.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/multiple-issues-fix.yml" "test/testdata/configs/multiple-issues-fix.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/output.yml" "test/testdata/configs/output.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/path-except.yml" "test/testdata/configs/path-except.yml"

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test from this PR
go test -v ./test -run TestPathPrefix
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
