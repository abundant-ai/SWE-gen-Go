#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
# Note: Do NOT set GL_TEST_RUN=1 here because it suppresses deprecation warnings!

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/golinters"
cp "/tests/pkg/golinters/misspell_test.go" "pkg/golinters/misspell_test.go"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/misspell_custom.yml" "test/testdata/configs/misspell_custom.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/misspell_custom.go" "test/testdata/misspell_custom.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# Test files: pkg/golinters/misspell_test.go (and related testdata)
go test -v ./pkg/golinters/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
