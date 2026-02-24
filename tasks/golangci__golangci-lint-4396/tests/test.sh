#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/go-header-fix.yml" "test/testdata/configs/go-header-fix.yml"
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/go-header_1.go" "test/testdata/fix/in/go-header_1.go"
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/go-header_2.go" "test/testdata/fix/in/go-header_2.go"
mkdir -p "test/testdata/fix/in"
cp "/tests/testdata/fix/in/go-header_3.go" "test/testdata/fix/in/go-header_3.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/go-header_1.go" "test/testdata/fix/out/go-header_1.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/go-header_2.go" "test/testdata/fix/out/go-header_2.go"
mkdir -p "test/testdata/fix/out"
cp "/tests/testdata/fix/out/go-header_3.go" "test/testdata/fix/out/go-header_3.go"
mkdir -p "test/testshared"
cp "/tests/testshared/directives.go" "test/testshared/directives.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR (go-header fix tests)
go test -v -run TestFix ./test/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
