#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/depguard.yml" "test/testdata/configs/depguard.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/depguard_additional_guards.yml" "test/testdata/configs/depguard_additional_guards.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/depguard_ignore_file_rules.yml" "test/testdata/configs/depguard_ignore_file_rules.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/depguard.go" "test/testdata/depguard.go"
mkdir -p "test/testdata"
cp "/tests/testdata/depguard_additional_guards.go" "test/testdata/depguard_additional_guards.go"
mkdir -p "test/testdata"
cp "/tests/testdata/depguard_ignore_file_rules.go" "test/testdata/depguard_ignore_file_rules.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for depguard test files
# The test framework will find depguard.go, depguard_additional_guards.go, and depguard_ignore_file_rules.go in testdata and run them
go test -v ./test -run TestSourcesFromTestdata/depguard.go
test_status_1=$?

go test -v ./test -run TestSourcesFromTestdata/depguard_additional_guards.go
test_status_2=$?

go test -v ./test -run TestSourcesFromTestdata/depguard_ignore_file_rules.go
test_status_3=$?

# All tests must pass for overall success
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ] && [ $test_status_3 -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
