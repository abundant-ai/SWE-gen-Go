#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/lint"
cp "/tests/pkg/lint/package_test.go" "pkg/lint/package_test.go"
mkdir -p "pkg/result/processors"
cp "/tests/pkg/result/processors/skip_dirs_test.go" "pkg/result/processors/skip_dirs_test.go"

# Run the specific test files for this PR
go test -v ./pkg/lint -run TestPackage
test_status_1=$?

go test -v ./pkg/result/processors -run TestSkipDirs
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
