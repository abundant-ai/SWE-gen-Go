#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files
mkdir -p "test"
cp "/tests/fix_test.go" "test/fix_test.go"
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"

# Rebuild golangci-lint binary
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Verify go.mod has correct version (1.20)
if grep -q "^go 1.20" go.mod; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
