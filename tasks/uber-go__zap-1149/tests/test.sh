#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/writer_test.go" "writer_test.go"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.mod" "zapgrpc/internal/test/go.mod"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.sum" "zapgrpc/internal/test/go.sum"

# Run tests in the main package
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
