#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"
mkdir -p "."
cp "/tests/utils_test.go" "utils_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run only the specific tests added in this PR
go test -v -run='TestContextRenderUTF8Attachment|TestIsASCII' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
