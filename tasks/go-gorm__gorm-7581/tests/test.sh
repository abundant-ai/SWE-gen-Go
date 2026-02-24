#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
# association_generics_test.go is deleted in BASE, only copy if it exists in /tests
[ -f "/tests/association_generics_test.go" ] && cp "/tests/association_generics_test.go" "tests/association_generics_test.go"
cp "/tests/associations_has_many_test.go" "tests/associations_has_many_test.go"
cp "/tests/associations_test.go" "tests/associations_test.go"
cp "/tests/generics_test.go" "tests/generics_test.go"
cp "/tests/go.mod" "tests/go.mod"

# Refresh test module dependencies after copying go.mod
cd tests
go mod tidy
go mod download

# Run all tests in the tests package
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
