#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/scopes_test.go" "tests/scopes_test.go"

# Remove all other test files in tests/ except the one we need
# Keep: scopes_test.go, tests_test.go (package setup), helper_test.go (test helpers), sql_builder_test.go (for assertEqualSQL)
cd tests
for f in *_test.go; do
  if [ "$f" != "scopes_test.go" ] && [ "$f" != "tests_test.go" ] && [ "$f" != "helper_test.go" ] && [ "$f" != "sql_builder_test.go" ]; then
    rm -f "$f"
  fi
done
cd ..

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
# The -mod=mod flag allows go to modify go.mod/go.sum as needed
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run tests in tests/ directory (only scopes_test.go and helpers remain)
cd /app/gorm/tests && go test -mod=mod -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
