#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test/testdata/spancheck/configs"
cp "/tests/testdata/spancheck/configs/enable_all.yml" "test/testdata/spancheck/configs/enable_all.yml"
mkdir -p "test/testdata/spancheck"
cp "/tests/testdata/spancheck/go.mod" "test/testdata/spancheck/go.mod"
mkdir -p "test/testdata/spancheck"
cp "/tests/testdata/spancheck/go.sum" "test/testdata/spancheck/go.sum"
mkdir -p "test/testdata/spancheck"
cp "/tests/testdata/spancheck/spancheck_default.go" "test/testdata/spancheck/spancheck_default.go"
mkdir -p "test/testdata/spancheck"
cp "/tests/testdata/spancheck/spancheck_enable_all.go" "test/testdata/spancheck/spancheck_enable_all.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR (spancheck-related tests)
go test -v ./test -run TestSourcesFromTestdataSubDir/spancheck
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
