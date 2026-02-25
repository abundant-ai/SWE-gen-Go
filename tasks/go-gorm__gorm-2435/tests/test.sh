#!/bin/bash

cd /app/src

# Remove other test files to avoid compilation errors from the BASE state
# Keep only callback_system_test.go which will be updated to HEAD state
for f in *_test.go; do
    if [ "$f" != "callback_system_test.go" ]; then
        mv "$f" "$f.bak"
    fi
done

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/callback_system_test.go" "callback_system_test.go"

# Clean Go module cache, tidy, and download dependencies after updating test files
rm -f go.sum
go mod tidy
go mod download

# Run the specific tests from callback_system_test.go
go test -v -run '^Test.*Callback' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
