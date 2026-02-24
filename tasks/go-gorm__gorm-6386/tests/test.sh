#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
# Note: constraint_test.go was renamed from check_test.go in the fix, so remove the old file
rm -f schema/check_test.go
cp "/tests/schema/constraint_test.go" "schema/constraint_test.go"
cp "/tests/schema/index_test.go" "schema/index_test.go"

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
# The -mod=mod flag allows go to modify go.mod/go.sum as needed
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run specific tests from constraint_test.go and index_test.go only
# Use the default sqlite driver which doesn't require external DB
cd schema && go test -mod=mod -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
