#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/fix_test.go" "test/fix_test.go"
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test/testshared"
cp "/tests/testshared/testshared.go" "test/testshared/testshared.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the entire test package to validate the fix
# The fix should make TestEnabledLinters pass by properly detecting Go version and inactivating interfacer
go test -v ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
