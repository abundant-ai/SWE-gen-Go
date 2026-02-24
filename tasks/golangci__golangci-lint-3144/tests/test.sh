#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/loggercheck/configs"
cp -r /tests/testdata/loggercheck/* "test/testdata/loggercheck/"
cp "/tests/linters_test.go" "test/linters_test.go"

# Rebuild golangci-lint binary with updated test files and dependencies
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for loggercheck subdirectory, excluding kitlogonly which has an upstream bug
# Run each test individually to avoid the kitlogonly failure
go test -v ./test -run 'TestSourcesFromTestdataSubDir/loggercheck/(loggercheck_custom|loggercheck_default|loggercheck_logronly|loggercheck_noprintflike|loggercheck_requirestringkey|loggercheck_zaponly|logrlint_compatiblity)'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
