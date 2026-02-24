#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
# Note: Do NOT set GL_TEST_RUN=1 here because it suppresses deprecation warnings!

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/configuration_file_test.go" "test/configuration_file_test.go"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/govet_fieldalignment.yml" "test/testdata/configs/govet_fieldalignment.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/govet_ifaceassert.yml" "test/testdata/configs/govet_ifaceassert.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/testifylint_bool_compare_only.yml" "test/testdata/configs/testifylint_bool_compare_only.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/testifylint_require_error_only.yml" "test/testdata/configs/testifylint_require_error_only.yml"
mkdir -p "test/testdata_etc/unused_exported"
cp "/tests/testdata_etc/unused_exported/golangci.yml" "test/testdata_etc/unused_exported/golangci.yml"

# Delete files that were removed in this PR
rm -f "test/testdata/configs/importas_noalias.yml"
rm -f "test/testdata/importas_noalias.go"

# Run the specific test for this PR
go test -v -run Test_validateTestConfigurationFiles ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
