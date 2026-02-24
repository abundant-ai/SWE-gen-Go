#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/bench_decode_test.go" "bench_decode_test.go"

# Run the benchmark tests from bench_decode_test.go and capture output
test_output=$(go test -v -bench=BenchmarkDecode -run=^$ -benchtime=1x . 2>&1)
test_status=$?
echo "$test_output"

# Check if the output contains the error messages that indicate the bug
# The bug causes "getting command info" error messages to be logged
if echo "$test_output" | grep -q "getting command info"; then
    echo "FAIL: Bug detected - cluster client is fetching command info when it shouldn't"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
