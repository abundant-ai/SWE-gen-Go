#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/config"
cp "/tests/pkg/config/output_test.go" "pkg/config/output_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/sort_results_test.go" "pkg/result/processors/sort_results_test.go"
mkdir -p "test"
cp "/tests/run_test.go" "test/run_test.go"

# Run the specific test files from this PR and capture combined status
exit_code=0
go test -v ./pkg/config -run TestOutput_Validate || exit_code=1
go test -v ./pkg/result/processors -run TestSortResults_Process || exit_code=1
go test -v ./test -run TestSortedResults || exit_code=1

test_status=$exit_code

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
