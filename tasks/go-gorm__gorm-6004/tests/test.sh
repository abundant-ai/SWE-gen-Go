#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
cp "/tests/error_translator_test.go" "tests/error_translator_test.go"
mkdir -p "utils/tests"
cp "/tests/utils/tests/dummy_dialecter.go" "utils/tests/dummy_dialecter.go"

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run tests in error_translator_test.go
cd /app/gorm/tests && go test -mod=mod -v -run "TestDialectorWithErrorTranslatorSupport"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
