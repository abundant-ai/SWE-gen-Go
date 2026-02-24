#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
cp "/tests/prepared_stmt_test.go" "tests/prepared_stmt_test.go"

# Download compatible test dependencies (v1.3.x versions compatible with this GORM version)
go get gorm.io/driver/sqlite@v1.3.6 gorm.io/driver/mysql@v1.3.6 gorm.io/driver/postgres@v1.3.10 gorm.io/driver/sqlserver@v1.3.2 2>/dev/null || true

# Run the specific tests in the tests package (TestPreparedStmt* tests from prepared_stmt_test.go)
cd /app/gorm/tests && go test -mod=mod -v -run '^TestPreparedStmt'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
