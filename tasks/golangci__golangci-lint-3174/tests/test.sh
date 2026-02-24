#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gofmt_rewrite_rules.yml" "test/testdata/configs/gofmt_rewrite_rules.yml"
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/gofmt_rewrite_rules.go" "test/testdata/fix/in/gofmt_rewrite_rules.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/gofmt_rewrite_rules.go" "test/testdata/fix/out/gofmt_rewrite_rules.go"
mkdir -p "test/testdata"
cp "/tests/testdata/gofmt_rewrite_rules.go" "test/testdata/gofmt_rewrite_rules.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the fix test for gofmt_rewrite_rules (tests that rewrite rules work correctly)
go test -v -run "TestFix/gofmt_rewrite_rules.go" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
