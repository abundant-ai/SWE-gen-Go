#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/sloglint_args_on_sep_lines.yml" "test/testdata/configs/sloglint_args_on_sep_lines.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/sloglint_attr_only.yml" "test/testdata/configs/sloglint_attr_only.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/sloglint_kv_only.yml" "test/testdata/configs/sloglint_kv_only.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/sloglint_no_raw_keys.yml" "test/testdata/configs/sloglint_no_raw_keys.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/sloglint.go" "test/testdata/sloglint.go"
mkdir -p "test/testdata"
cp "/tests/testdata/sloglint_args_on_sep_lines.go" "test/testdata/sloglint_args_on_sep_lines.go"
mkdir -p "test/testdata"
cp "/tests/testdata/sloglint_attr_only.go" "test/testdata/sloglint_attr_only.go"
mkdir -p "test/testdata"
cp "/tests/testdata/sloglint_kv_only.go" "test/testdata/sloglint_kv_only.go"
mkdir -p "test/testdata"
cp "/tests/testdata/sloglint_no_raw_keys.go" "test/testdata/sloglint_no_raw_keys.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# The test framework runs golangci-lint against files in test/testdata
# We run the TestSourcesFromTestdata test filtered to just our specific files
go test -v -run "TestSourcesFromTestdata/sloglint.go" ./test
test_status_1=$?

go test -v -run "TestSourcesFromTestdata/sloglint_args_on_sep_lines.go" ./test
test_status_2=$?

go test -v -run "TestSourcesFromTestdata/sloglint_attr_only.go" ./test
test_status_3=$?

go test -v -run "TestSourcesFromTestdata/sloglint_kv_only.go" ./test
test_status_4=$?

go test -v -run "TestSourcesFromTestdata/sloglint_no_raw_keys.go" ./test
test_status_5=$?

# All tests must pass
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ] && [ $test_status_3 -eq 0 ] && [ $test_status_4 -eq 0 ] && [ $test_status_5 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
