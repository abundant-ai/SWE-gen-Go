#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/usestdlibvars_non_default.yml" "test/testdata/configs/usestdlibvars_non_default.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/usestdlibvars_non_default.go" "test/testdata/usestdlibvars_non_default.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test for usestdlibvars_non_default.go
# The test framework will find usestdlibvars_non_default.go in testdata and run it
go test -v ./test -run TestSourcesFromTestdata/usestdlibvars_non_default.go
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
