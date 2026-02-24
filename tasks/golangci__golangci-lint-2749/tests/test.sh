#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata"
cp "/tests/testdata/nosprintfhostport.go" "test/testdata/nosprintfhostport.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test for nosprintfhostport (TestSourcesFromTestdataWithIssuesDir runs all testdata files)
# The test file has //args: -Enosprintfhostport which tells the test framework what linter to enable
go test -v ./test -run '^TestSourcesFromTestdataWithIssuesDir/nosprintfhostport\.go$'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
