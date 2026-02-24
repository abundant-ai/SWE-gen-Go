#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/exclude_rules_test.go" "pkg/result/processors/exclude_rules_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/severity_rules_test.go" "pkg/result/processors/severity_rules_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/skip_files_test.go" "pkg/result/processors/skip_files_test.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run tests for the specific package
go test -v ./pkg/result/processors

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
