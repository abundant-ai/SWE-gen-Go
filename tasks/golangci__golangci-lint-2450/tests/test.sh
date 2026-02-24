#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/ruleguard"
cp "/tests/ruleguard/rangeExprCopy.go" "test/ruleguard/rangeExprCopy.go"
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/gocritic.go" "test/testdata/fix/in/gocritic.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/gocritic.go" "test/testdata/fix/out/gocritic.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific fix test for gocritic to validate the autofix functionality
go test -v -run "TestFix/gocritic.go" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
