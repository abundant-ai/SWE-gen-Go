#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/buffer_size_test.go" "internal/pool/buffer_size_test.go"

# The fix changes DefaultBufferSize from 256*1024 to 32*1024
# Check if the correct value (32 KiB = 32768 bytes) is set
if grep -q "const DefaultBufferSize = 32 \* 1024" internal/proto/reader.go; then
  echo "✓ Correct: DefaultBufferSize is set to 32 KiB"
  test_status=0
else
  echo "✗ Incorrect: DefaultBufferSize is not set to 32 KiB"
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
