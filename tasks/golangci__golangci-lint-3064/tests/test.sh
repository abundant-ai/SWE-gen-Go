#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/reassign_patterns.yml" "test/testdata/configs/reassign_patterns.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/reassign.go" "test/testdata/reassign.go"
mkdir -p "test/testdata"
cp "/tests/testdata/reassign_patterns.go" "test/testdata/reassign_patterns.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test for reassign
go test -v ./test -run 'TestSourcesFromTestdata/reassign'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
