#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/golinters"
cp "/tests/pkg/golinters/gocritic_test.go" "pkg/golinters/gocritic_test.go"
mkdir -p "test/ruleguard"
cp "/tests/ruleguard/README.md" "test/ruleguard/README.md"
mkdir -p "test/ruleguard"
cp "/tests/ruleguard/preferWriteString.go" "test/ruleguard/preferWriteString.go"
mkdir -p "test/ruleguard"
cp "/tests/ruleguard/rangeExprCopy.go" "test/ruleguard/rangeExprCopy.go"
mkdir -p "test/ruleguard"
cp "/tests/ruleguard/stringsSimplify.go" "test/ruleguard/stringsSimplify.go"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gocritic-fix.yml" "test/testdata/configs/gocritic-fix.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gocritic.yml" "test/testdata/configs/gocritic.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/gocritic.go" "test/testdata/gocritic.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR (gocritic-related tests)
go test -v ./pkg/golinters -run TestGocritic
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
