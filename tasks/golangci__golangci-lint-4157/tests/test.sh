#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/perfsprint_int_conversion.yml" "test/testdata/configs/perfsprint_int_conversion.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/perfsprint.go" "test/testdata/perfsprint.go"
mkdir -p "test/testdata"
cp "/tests/testdata/perfsprint_int_conversion.go" "test/testdata/perfsprint_int_conversion.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# The test framework runs golangci-lint against files in test/testdata
# We run the TestSourcesFromTestdata test filtered to just our specific files
go test -v -run "TestSourcesFromTestdata/perfsprint.go" ./test
test_status_1=$?

go test -v -run "TestSourcesFromTestdata/perfsprint_int_conversion.go" ./test
test_status_2=$?

# Both tests must pass
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ]; then
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
