#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/exhaustive_checking_strategy_name.yml" "test/testdata/configs/exhaustive_checking_strategy_name.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/exhaustive_checking_strategy_value.yml" "test/testdata/configs/exhaustive_checking_strategy_value.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/exhaustive_ignore_enum_members.yml" "test/testdata/configs/exhaustive_ignore_enum_members.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/exhaustive_checking_strategy_name.go" "test/testdata/exhaustive_checking_strategy_name.go"
mkdir -p "test/testdata"
cp "/tests/testdata/exhaustive_checking_strategy_value.go" "test/testdata/exhaustive_checking_strategy_value.go"
mkdir -p "test/testdata"
cp "/tests/testdata/exhaustive_default.go" "test/testdata/exhaustive_default.go"
mkdir -p "test/testdata"
cp "/tests/testdata/exhaustive_ignore_enum_members.go" "test/testdata/exhaustive_ignore_enum_members.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for exhaustive linter testdata files
go test -v -run "TestSourcesFromTestdataWithIssuesDir/(exhaustive_checking_strategy_name\.go|exhaustive_checking_strategy_value\.go|exhaustive_default\.go|exhaustive_ignore_enum_members\.go)" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
