#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
# Note: Do NOT set GL_TEST_RUN=1 here because it suppresses deprecation warnings!

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/config"
cp "/tests/pkg/config/output_test.go" "pkg/config/output_test.go"
mkdir -p "pkg/printers"
cp "/tests/pkg/printers/printer_test.go" "pkg/printers/printer_test.go"

# Run the specific tests for this PR
go test -v ./pkg/config ./pkg/printers
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
