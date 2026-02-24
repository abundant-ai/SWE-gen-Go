#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/buffer_size_test.go" "internal/pool/buffer_size_test.go"

# Run only the buffer size tests using Ginkgo focus
go test -v ./internal/pool -run "TestGinkgoSuite" -ginkgo.focus "Buffer Size Configuration"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
