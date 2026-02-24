#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test/testdata/zerologlint"
cp "/tests/testdata/zerologlint/go.mod" "test/testdata/zerologlint/go.mod"
mkdir -p "test/testdata/zerologlint"
cp "/tests/testdata/zerologlint/go.sum" "test/testdata/zerologlint/go.sum"
mkdir -p "test/testdata/zerologlint"
cp "/tests/testdata/zerologlint/zerologlint.go" "test/testdata/zerologlint/zerologlint.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run only the zerologlint subtest from TestSourcesFromTestdataSubDir
# The test file uses testdata from test/testdata/zerologlint/
go test -v -run 'TestSourcesFromTestdataSubDir/zerologlint' ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
