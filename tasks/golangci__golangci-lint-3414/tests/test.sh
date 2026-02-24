#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/notcompiles"
cp "/tests/testdata/notcompiles/typecheck_many_issues.go" "test/testdata/notcompiles/typecheck_many_issues.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the TestTypecheck test which tests files in testdata/notcompiles
# This includes our test file: typecheck_many_issues.go
go test -v ./test -run TestTypecheck

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
