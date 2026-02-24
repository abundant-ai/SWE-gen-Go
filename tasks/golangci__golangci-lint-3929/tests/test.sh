#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/lint/lintersdb"
cp "/tests/pkg/lint/lintersdb/enabled_set_test.go" "pkg/lint/lintersdb/enabled_set_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/nolint_test.go" "pkg/result/processors/nolint_test.go"
mkdir -p "test"
cp "/tests/enabled_linters_test.go" "test/enabled_linters_test.go"
mkdir -p "test"
cp "/tests/run_test.go" "test/run_test.go"
mkdir -p "test/testdata/linedirective"
cp "/tests/testdata/linedirective/gomodguard.yml" "test/testdata/linedirective/gomodguard.yml"
mkdir -p "test/testdata/linedirective"
cp "/tests/testdata/linedirective/hello.go" "test/testdata/linedirective/hello.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# The test files are related to linedirective handling
# We run tests from the specific packages that were modified
go test -v ./pkg/lint/lintersdb -run TestEnabledSet
go test -v ./pkg/result/processors -run TestNolint
go test -v ./test -run "TestSourcesFromTestdata/linedirective"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
