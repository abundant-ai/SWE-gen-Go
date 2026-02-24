#!/bin/bash

cd /app/src

# Set CGO_ENABLED for race detector (as used in CI)
export CGO_ENABLED=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/encoding"
cp "/tests/internal/encoding/decoder_test.go" "internal/encoding/decoder_test.go"
mkdir -p "internal/encoding"
cp "/tests/internal/encoding/encoder_test.go" "internal/encoding/encoder_test.go"

# Run tests for the internal/encoding package with race detector
go test -v -race ./internal/encoding
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
