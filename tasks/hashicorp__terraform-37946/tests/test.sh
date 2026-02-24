#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/backend/local"
cp "/tests/internal/backend/local/backend_local_test.go" "internal/backend/local/backend_local_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/apply_test.go" "internal/command/apply_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/command_test.go" "internal/command/command_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/graph_test.go" "internal/command/graph_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/plan_test.go" "internal/command/plan_test.go"
mkdir -p "internal/plans/planfile"
cp "/tests/internal/plans/planfile/planfile_test.go" "internal/plans/planfile/planfile_test.go"
mkdir -p "internal/plans/planfile"
cp "/tests/internal/plans/planfile/tfplan_test.go" "internal/plans/planfile/tfplan_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_test.go" "internal/terraform/context_test.go"

# Run tests for the specific packages containing the modified test files
go test -v ./internal/backend/local ./internal/command ./internal/plans/planfile ./internal/terraform
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
