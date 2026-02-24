#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/forbidigo_struct.yml" "test/testdata/configs/forbidigo_struct.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/forbidigo_example.go" "test/testdata/forbidigo_example.go"
mkdir -p "test/testdata"
cp "/tests/testdata/forbidigo_struct_config.go" "test/testdata/forbidigo_struct_config.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run integration test for forbidigo_struct_config using TestSourcesFromTestdata
go test -v -run 'TestSourcesFromTestdata/forbidigo_struct_config' ./test

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
