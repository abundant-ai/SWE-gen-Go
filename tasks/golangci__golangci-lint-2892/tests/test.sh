#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/gci.go" "test/testdata/fix/in/gci.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/gci.go" "test/testdata/fix/out/gci.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test for gci fix
go test -v ./test -run 'TestFix/gci'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
