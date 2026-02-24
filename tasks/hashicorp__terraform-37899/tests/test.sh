#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/backend/pluggable"
cp "/tests/internal/backend/pluggable/pluggable_test.go" "internal/backend/pluggable/pluggable_test.go"
mkdir -p "internal/plugin6"
cp "/tests/internal/plugin6/grpc_provider_test.go" "internal/plugin6/grpc_provider_test.go"

# Run tests for the specific packages
go test -v ./internal/backend/pluggable ./internal/plugin6
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
