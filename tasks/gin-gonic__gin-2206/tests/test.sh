#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/bytesconv"
cp "/tests/internal/bytesconv/bytesconv_test.go" "internal/bytesconv/bytesconv_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests in the internal/bytesconv package
go test -v ./internal/bytesconv
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
