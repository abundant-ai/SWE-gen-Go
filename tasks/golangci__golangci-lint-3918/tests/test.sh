#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/misspell.yml" "test/testdata/configs/misspell.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/misspell.go" "test/testdata/misspell.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test for misspell.go
# The test framework will find misspell.go in testdata and run it
go test -v ./test -run TestSourcesFromTestdata/misspell.go
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
