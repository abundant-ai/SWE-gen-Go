#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/binding_test.go" "binding/binding_test.go"
mkdir -p "binding"
cp "/tests/binding/toml_test.go" "binding/toml_test.go"
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run TOML-related tests that were modified/added in this PR
go test -v -run='Test.*TOML' ./binding
test_status_binding=$?

go test -v -run='TestContextShouldBindWithTOML' .
test_status_context=$?

# Combined status - both must pass
if [ $test_status_binding -eq 0 ] && [ $test_status_context -eq 0 ]; then
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
