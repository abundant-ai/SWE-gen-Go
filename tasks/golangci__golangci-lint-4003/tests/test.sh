#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/whitespace.go" "test/testdata/fix/in/whitespace.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/whitespace.go" "test/testdata/fix/out/whitespace.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# The test framework runs golangci-lint fix against files in test/testdata/fix/in
# We run the TestFix test filtered to just whitespace.go
go test -v -run "TestFix/whitespace.go" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
