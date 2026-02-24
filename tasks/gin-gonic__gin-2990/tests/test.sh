#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/binding_test.go" "binding/binding_test.go"
mkdir -p "binding"
cp "/tests/binding/default_validator_test.go" "binding/default_validator_test.go"
mkdir -p "binding"
cp "/tests/binding/form_mapping_test.go" "binding/form_mapping_test.go"
mkdir -p "binding"
cp "/tests/binding/msgpack_test.go" "binding/msgpack_test.go"
mkdir -p "binding"
cp "/tests/binding/multipart_form_mapping_test.go" "binding/multipart_form_mapping_test.go"
mkdir -p "binding"
cp "/tests/binding/validate_test.go" "binding/validate_test.go"
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"
mkdir -p "."
cp "/tests/errors_test.go" "errors_test.go"
mkdir -p "."
cp "/tests/gin_test.go" "gin_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests in the binding package and root package where test files were modified
# Skip TestContextFormFileFailed17 which is a Go 1.17-specific test that fails on Go 1.23
go test -v -skip=TestContextFormFileFailed17 ./binding .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
