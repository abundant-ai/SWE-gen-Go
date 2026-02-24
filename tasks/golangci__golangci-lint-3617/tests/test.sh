#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/exclude_rules_test.go" "pkg/result/processors/exclude_rules_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/severity_rules_test.go" "pkg/result/processors/severity_rules_test.go"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/path-except.yml" "test/testdata/configs/path-except.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/path_except.go" "test/testdata/path_except.go"
mkdir -p "test/testdata"
cp "/tests/testdata/path_except_test.go" "test/testdata/path_except_test.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run unit tests in pkg/result/processors package (contains exclude_rules_test.go and severity_rules_test.go)
go test -v ./pkg/result/processors

test_status=$?

# Also run integration test for path_except using TestSourcesFromTestdata
if [ $test_status -eq 0 ]; then
  go test -v -run 'TestSourcesFromTestdata/path_except' ./test
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
