#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata"
cp "/tests/testdata/err113.go" "test/testdata/err113.go"

# Remove goerr113.go (the old filename that exists at BASE but not at HEAD)
# This file was renamed to err113.go in the PR
rm -f "test/testdata/goerr113.go"

# Run the specific test for err113.go testdata file
# The test framework automatically discovers and runs tests for testdata files
go test -v ./test -run TestSourcesFromTestdata/err113.go
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
