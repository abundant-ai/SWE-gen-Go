#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testshared"
cp "/tests/testshared/runner.go" "test/testshared/runner.go"
mkdir -p "test/testshared"
cp "/tests/testshared/runner_unix.go" "test/testshared/runner_unix.go"
mkdir -p "test/testshared"
cp "/tests/testshared/runner_windows.go" "test/testshared/runner_windows.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run tests in test/testshared package which includes the modified runner files
go test -v ./test/testshared/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
