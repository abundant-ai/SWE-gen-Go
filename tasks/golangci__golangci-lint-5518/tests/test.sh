#!/bin/bash

cd /app/src

# Set environment variables for tests (already set in Dockerfile but ensure they're available)
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/exclusion_rules_test.go" "pkg/result/processors/exclusion_rules_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/severity_test.go" "pkg/result/processors/severity_test.go"

# Re-download dependencies and rebuild (in case solve.sh changed go.mod)
go mod download
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test files for this PR
# Run tests for the processors package with specific test functions
go test -v -run 'TestExclusionRules|TestSeverity' ./pkg/result/processors
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
