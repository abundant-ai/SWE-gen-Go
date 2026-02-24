#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gci.yml" "test/testdata/configs/gci.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/gci.go" "test/testdata/gci.go"
mkdir -p "test/testdata/gci"
cp "/tests/testdata/gci/gci.go" "test/testdata/gci/gci.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific GCI test to validate the fix
go test -v -run TestGciLocal ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
