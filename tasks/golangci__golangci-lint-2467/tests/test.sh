#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/depguard_additional_guards.yml" "test/testdata/configs/depguard_additional_guards.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/depguard_ignore_file_rules.yml" "test/testdata/configs/depguard_ignore_file_rules.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/depguard_additional_guards.go" "test/testdata/depguard_additional_guards.go"
mkdir -p "test/testdata"
cp "/tests/testdata/depguard_ignore_file_rules.go" "test/testdata/depguard_ignore_file_rules.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific depguard tests to validate the fix
go test -v -run "TestSourcesFromTestdataWithIssuesDir/depguard_additional_guards.go|TestSourcesFromTestdataWithIssuesDir/depguard_ignore_file_rules.go" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
