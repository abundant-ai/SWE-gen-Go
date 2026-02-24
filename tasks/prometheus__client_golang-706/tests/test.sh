#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/counter_test.go" "prometheus/counter_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"

# Fix string conversion issues in copied test files (pre-existing bugs at this commit)
sed -i "s/string('A' + picks\[i\])/string('A' + rune(picks[i]))/g" prometheus/histogram_test.go
sed -i "s/string('A' + i)/string('A' + rune(i))/g" prometheus/histogram_test.go

# Run tests for the specific package that was modified
go test -v ./prometheus 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
