#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/util"
cp "/tests/internal/util/convert_test.go" "internal/util/convert_test.go"
mkdir -p "."
cp "/tests/search_test.go" "search_test.go"

# Run tests for the specific files modified in this PR
# Tests in root directory (search_test.go)
go test -v -skip "TestGinkgoSuite|Example" .
test_status_1=$?

# Tests in internal/util package (convert_test.go)
go test -v ./internal/util/...
test_status_2=$?

# Overall test status - fail if any test failed
test_status=0
if [ $test_status_1 -ne 0 ] || [ $test_status_2 -ne 0 ]; then
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
