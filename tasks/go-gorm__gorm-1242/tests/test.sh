#!/bin/bash

cd /app/src

# Use testdb dialect to avoid needing database drivers
export GORM_DIALECT=testdb

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/errors_test.go" "errors_test.go"
cp "/tests/main_test.go" "main_test.go"

# Remove mssql dialect import from main_test.go which has complex dependencies
sed -i '/_.*"github.com\/jinzhu\/gorm\/dialects\/mssql"/d' main_test.go

# Run the specific test that was added in this PR
go test -v -run '^TestErrorsCanBeUsedOutsideGorm$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
