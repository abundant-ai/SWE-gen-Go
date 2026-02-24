#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/fix_test.go" "test/fix_test.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the fix tests (TestFix and TestFix_pathPrefix), excluding gocritic which has unrelated failures
go test -v -run 'TestFix/(gci\.go|godot\.go|gofmt\.go|gofmt_rewrite_rules\.go|gofumpt\.go|goimports\.go|misspell\.go|nolintlint\.go|whitespace\.go)$' ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
