#!/bin/bash

cd /app/src

# Use testdb dialect to avoid needing database drivers
export GORM_DIALECT=testdb

# Remove mssql dialect import from main_test.go which has complex dependencies
sed -i '/_.*"github.com\/jinzhu\/gorm\/dialects\/mssql"/d' main_test.go

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/migration_test.go" "migration_test.go"

# Run all tests in migration_test.go
go test -v -run '^(TestIndexes|TestAutoMigration|TestCreateAndAutomigrateTransaction|TestMultipleIndexes|TestModifyColumnType)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
