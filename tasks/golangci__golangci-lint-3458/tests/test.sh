#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gosmopolitan_allow_time_local.yml" "test/testdata/configs/gosmopolitan_allow_time_local.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gosmopolitan_dont_ignore_tests.yml" "test/testdata/configs/gosmopolitan_dont_ignore_tests.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gosmopolitan_escape_hatches.yml" "test/testdata/configs/gosmopolitan_escape_hatches.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/gosmopolitan_scripts.yml" "test/testdata/configs/gosmopolitan_scripts.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/gosmopolitan.go" "test/testdata/gosmopolitan.go"
mkdir -p "test/testdata"
cp "/tests/testdata/gosmopolitan_allow_time_local.go" "test/testdata/gosmopolitan_allow_time_local.go"
mkdir -p "test/testdata"
cp "/tests/testdata/gosmopolitan_dont_ignore_test.go" "test/testdata/gosmopolitan_dont_ignore_test.go"
mkdir -p "test/testdata"
cp "/tests/testdata/gosmopolitan_escape_hatches.go" "test/testdata/gosmopolitan_escape_hatches.go"
mkdir -p "test/testdata"
cp "/tests/testdata/gosmopolitan_ignore_test.go" "test/testdata/gosmopolitan_ignore_test.go"
mkdir -p "test/testdata"
cp "/tests/testdata/gosmopolitan_scripts.go" "test/testdata/gosmopolitan_scripts.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run tests for the specific gosmopolitan testdata files
# Using regex pattern to match all gosmopolitan test files
go test -v ./test -run TestSourcesFromTestdata/gosmopolitan

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
