#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extra/redisotel"
cp "/tests/extra/redisotel/redisotel_test.go" "extra/redisotel/redisotel_test.go"

# Run tests in extra/redisotel package (it's a separate module)
cd extra/redisotel
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
