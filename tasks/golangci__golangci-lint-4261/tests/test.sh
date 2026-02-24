#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/inamedparam_skip_single_param.yml" "test/testdata/configs/inamedparam_skip_single_param.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/inamedparam_skip_single_param.go" "test/testdata/inamedparam_skip_single_param.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test for this PR
# The test framework runs golangci-lint against files in test/testdata
# We run the TestSourcesFromTestdata test filtered to just our specific file
go test -v -run "TestSourcesFromTestdata/inamedparam_skip_single_param.go" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
