#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command"
cp "/tests/internal/command/query_test.go" "internal/command/query_test.go"
mkdir -p "internal/plugin"
cp "/tests/internal/plugin/grpc_provider_test.go" "internal/plugin/grpc_provider_test.go"
mkdir -p "internal/plugin6"
cp "/tests/internal/plugin6/grpc_provider_test.go" "internal/plugin6/grpc_provider_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_plan_query_test.go" "internal/terraform/context_plan_query_test.go"

# Run tests for the specific packages containing the test files
go test -v ./internal/command ./internal/plugin ./internal/plugin6 ./internal/terraform
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
