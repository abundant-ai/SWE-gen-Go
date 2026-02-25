#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/jsonformat"
cp "/tests/internal/command/jsonformat/plan_test.go" "internal/command/jsonformat/plan_test.go"
mkdir -p "internal/command/jsonprovider"
cp "/tests/internal/command/jsonprovider/provider_test.go" "internal/command/jsonprovider/provider_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/show_test.go" "internal/command/show_test.go"
mkdir -p "internal/command/views"
cp "/tests/internal/command/views/operation_test.go" "internal/command/views/operation_test.go"
mkdir -p "internal/configs"
cp "/tests/internal/configs/action_test.go" "internal/configs/action_test.go"
mkdir -p "internal/plans/planfile"
cp "/tests/internal/plans/planfile/tfplan_test.go" "internal/plans/planfile/tfplan_test.go"
mkdir -p "internal/plugin"
cp "/tests/internal/plugin/grpc_provider_test.go" "internal/plugin/grpc_provider_test.go"
mkdir -p "internal/plugin6"
cp "/tests/internal/plugin6/grpc_provider_test.go" "internal/plugin6/grpc_provider_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_apply_action_test.go" "internal/terraform/context_apply_action_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/context_plan_actions_test.go" "internal/terraform/context_plan_actions_test.go"
mkdir -p "internal/terraform"
cp "/tests/internal/terraform/resource_provider_mock_test.go" "internal/terraform/resource_provider_mock_test.go"

# Run tests for the specific packages containing the test files
go test -v ./internal/command/jsonformat ./internal/command/jsonprovider ./internal/command ./internal/command/views ./internal/configs ./internal/plans/planfile ./internal/plugin ./internal/plugin6 ./internal/terraform
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
