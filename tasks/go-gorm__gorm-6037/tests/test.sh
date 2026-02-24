#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/hooks_test.go" "tests/hooks_test.go"

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run specific test (not entire test suite)
cd /app/gorm/tests && go test -mod=mod -v -run "TestUpdateCallbacks" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
