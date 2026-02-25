#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/ringbuffer"
cp "/tests/internal/ringbuffer/ring_buffer_benchmark_test.go" "internal/ringbuffer/ring_buffer_benchmark_test.go"
mkdir -p "internal/ringbuffer"
cp "/tests/internal/ringbuffer/ring_buffer_test.go" "internal/ringbuffer/ring_buffer_test.go"

# Run tests for the specific package
go test -v ./internal/ringbuffer/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
