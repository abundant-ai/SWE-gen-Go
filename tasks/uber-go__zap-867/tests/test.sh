#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "zapcore"
cp "/tests/zapcore/field_test.go" "zapcore/field_test.go"

# Run tests specifically for field_test.go (tests related to this PR)
go test -v ./zapcore -run "^(TestUnknownFieldType|TestFieldAddingError|TestFields)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
