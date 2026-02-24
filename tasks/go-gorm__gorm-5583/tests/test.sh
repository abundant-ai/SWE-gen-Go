#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
cp "/tests/joins_test.go" "tests/joins_test.go"

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
go get gorm.io/driver/sqlite@v1.4.3 gorm.io/driver/mysql@v1.4.3 gorm.io/driver/postgres@v1.4.4 gorm.io/driver/sqlserver@v1.4.1 2>/dev/null || true

# Run the specific tests in the tests package (TestJoin* tests from joins_test.go)
cd /app/gorm/tests && go test -mod=mod -v -run '^TestJoin'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
