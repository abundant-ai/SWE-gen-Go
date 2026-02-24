#!/bin/bash

cd /app/src

export TF_ACC=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/e2etest"
cp "/tests/internal/command/e2etest/pluggable_state_store_test.go" "internal/command/e2etest/pluggable_state_store_test.go"
mkdir -p "internal/command/e2etest"
cp "/tests/internal/command/e2etest/unmanaged_test.go" "internal/command/e2etest/unmanaged_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/init_test.go" "internal/command/init_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/meta_backend_test.go" "internal/command/meta_backend_test.go"

# Run pluggable state store tests
go test -v -timeout=30m \
  ./internal/command/e2etest -run "TestPrimary_stateStore_" \
  ./internal/command -run "TestMetaBackend_planLocal_stateStore"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
