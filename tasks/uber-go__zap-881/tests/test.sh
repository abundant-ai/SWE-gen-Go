#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/README.md" "zapgrpc/internal/test/README.md"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.mod" "zapgrpc/internal/test/go.mod"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.sum" "zapgrpc/internal/test/go.sum"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/grpc_test.go" "zapgrpc/internal/test/grpc_test.go"
mkdir -p "zapgrpc"
cp "/tests/zapgrpc/zapgrpc_test.go" "zapgrpc/zapgrpc_test.go"

# Run tests for the modified test files in zapgrpc package and internal test
go test -v ./zapgrpc/... -run "Test"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
