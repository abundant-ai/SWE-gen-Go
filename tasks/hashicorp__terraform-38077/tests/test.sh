#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/configs/configschema"
cp "/tests/internal/configs/configschema/validate_traversal_test.go" "internal/configs/configschema/validate_traversal_test.go"
mkdir -p "internal/deprecation"
cp "/tests/internal/deprecation/schema_test.go" "internal/deprecation/schema_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_validate_test.go" "internal/terraform/context_validate_test.go"

# Run tests for the specific packages
go test -v ./internal/configs/configschema ./internal/deprecation ./internal/terraform
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
