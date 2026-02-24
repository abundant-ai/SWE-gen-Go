#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
# Note: Do NOT set GL_TEST_RUN=1 here because it suppresses deprecation warnings!

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/config"
cp "/tests/pkg/config/config_test.go" "pkg/config/config_test.go"
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test"
cp "/tests/run_test.go" "test/run_test.go"
mkdir -p "test/testdata"
cp "/tests/testdata/copyloopvar.go" "test/testdata/copyloopvar.go"
mkdir -p "test/testdata"
cp "/tests/testdata/intrange.go" "test/testdata/intrange.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# Test files: pkg/config/config_test.go, test/linters_test.go, test/run_test.go (and related testdata)
# Only run the config test to validate the core IsGoGreaterThanOrEqual function
go test -v ./pkg/config/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
