#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_apply2_test.go" "internal/terraform/context_apply2_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_plan_actions_test.go" "internal/terraform/context_plan_actions_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_plan_query_test.go" "internal/terraform/context_plan_query_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_validate_test.go" "internal/terraform/context_validate_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/terraform_test.go" "internal/terraform/terraform_test.go"

# Run tests for the specific package containing the test files
go test -v ./internal/terraform
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
