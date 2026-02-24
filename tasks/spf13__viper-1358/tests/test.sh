#!/bin/bash

cd /app/src

# Set CGO_ENABLED for race detector (as used in CI)
export CGO_ENABLED=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/encoding/toml"
cp "/tests/internal/encoding/toml/codec2_test.go" "internal/encoding/toml/codec2_test.go"
mkdir -p "internal/encoding/toml"
cp "/tests/internal/encoding/toml/codec_test.go" "internal/encoding/toml/codec_test.go"

# Run only the specific test package with race detector
go test -v -race ./internal/encoding/toml
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
