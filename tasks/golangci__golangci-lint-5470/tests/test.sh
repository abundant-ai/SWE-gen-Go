#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Rebuild binary in case solve.sh made changes
go mod download
go build -o golangci-lint ./cmd/golangci-lint

# Test that the default show-stats behavior is correct
# In BASE (before fix): default is false (old behavior)
# In HEAD (after fix): default is true (new behavior)
# We test by running golangci-lint WITHOUT --show-stats flag and checking if stats appear

# Use existing test directory that's part of the module
testdir="test/testdata/minimalpkg"

# Run golangci-lint without --show-stats flag to test the default
output=$(./golangci-lint run --no-config --disable-all -Erevive "$testdir" 2>&1)

# Check if stats appear in output (stats start with "* " like "* revive: X")
if echo "$output" | grep -q "^\* "; then
	# Stats shown - default=true (correct for HEAD)
	test_status=0
else
	# Stats NOT shown - default=false (correct for BASE, incorrect for HEAD)
	test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
