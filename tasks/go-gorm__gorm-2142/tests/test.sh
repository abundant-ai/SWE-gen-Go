#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/create_test.go" "create_test.go"

# Clean Go module cache, tidy, and download dependencies after updating test files
rm -f go.sum
go mod tidy
go mod download

# Run the specific tests in create_test.go
go test -v -run '^(TestCreate|TestCreateEmptyStrut|TestCreateWithExistingTimestamp|TestCreateWithNowFuncOverride|TestCreateWithAutoIncrement|TestCreateWithNoGORMPrimayKey|TestCreateWithNoStdPrimaryKeyAndDefaultValues|TestAnonymousScanner|TestAnonymousField|TestSelectWithCreate|TestOmitWithCreate|TestCreateIgnore)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
