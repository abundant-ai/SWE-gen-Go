#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_plan2_test.go" "internal/terraform/context_plan2_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_validate_test.go" "internal/terraform/context_validate_test.go"
mkdir -p "internal/tfdiags"
cp "/tests/internal/tfdiags/diagnostic_extra_test.go" "internal/tfdiags/diagnostic_extra_test.go"
mkdir -p "internal/tfdiags"
cp "/tests/internal/tfdiags/testing_test.go" "internal/tfdiags/testing_test.go"

# Run tests for the specific packages
go test -v ./internal/terraform ./internal/tfdiags
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
