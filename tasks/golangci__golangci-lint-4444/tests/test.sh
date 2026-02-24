#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
# Note: Do NOT set GL_TEST_RUN=1 here because it suppresses deprecation warnings!

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/copyloopvar.yml" "test/testdata/configs/copyloopvar.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/copyloopvar.go" "test/testdata/copyloopvar.go"
mkdir -p "test/testdata"
cp "/tests/testdata/copyloopvar_custom.go" "test/testdata/copyloopvar_custom.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# The testdata files (copyloopvar.go, copyloopvar_custom.go) are tested by TestSourcesFromTestdata
# which runs on all *.go files in test/testdata directory
# We use -run to run specific test cases that match our copyloopvar test files
go test -v ./test/... -run "TestSourcesFromTestdata/copyloopvar"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
