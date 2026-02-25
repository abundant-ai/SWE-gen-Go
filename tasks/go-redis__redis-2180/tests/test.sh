#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/customvet/checks/setval"
cp "/tests/internal/customvet/checks/setval/setval_test.go" "internal/customvet/checks/setval/setval_test.go"

# Run the specific test package from the customvet module directory
cd internal/customvet
go test -v ./checks/setval/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
