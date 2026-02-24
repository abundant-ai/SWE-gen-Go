#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/custom_linter_goplugin.yml" "test/testdata/configs/custom_linter_goplugin.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/custom_linter_module.yml" "test/testdata/configs/custom_linter_module.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/custom_linter_notype.yml" "test/testdata/configs/custom_linter_notype.yml"

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Run the configuration file validation test
# This test validates all test configuration YAML files against the JSON schema
# The files we added are the custom_linter_* files which test the oneOf fix
go test -v ./test -run Test_validateTestConfigurationFiles
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
