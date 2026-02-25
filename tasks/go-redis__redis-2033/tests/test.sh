#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extra/redisotel"
cp "/tests/extra/redisotel/redisotel_test.go" "extra/redisotel/redisotel_test.go"

# Run the specific test package for this PR
# extra/redisotel has its own go.mod, so we need to cd into it
cd extra/redisotel && go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
