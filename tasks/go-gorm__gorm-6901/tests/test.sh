#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/query_test.go" "tests/query_test.go"

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
# The -mod=mod flag allows go to modify go.mod/go.sum as needed
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run specific tests from query_test.go only
# Use the default sqlite driver which doesn't require external DB
# The -run flag filters to only run tests defined in query_test.go
cd tests && go test -mod=mod -v . -run="TestFind|TestLast|TestFirstOrInit|TestFirstOrCreate|TestMapColumns"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
