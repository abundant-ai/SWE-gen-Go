#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/printers"
cp "/tests/pkg/printers/printer_test.go" "pkg/printers/printer_test.go"

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test file for this PR
go test -v ./pkg/printers/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
