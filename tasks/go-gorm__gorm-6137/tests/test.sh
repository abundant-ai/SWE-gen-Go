#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/schema/relationship_test.go" "schema/relationship_test.go"
cp "/tests/schema/schema_helper_test.go" "schema/schema_helper_test.go"
cp "/tests/preload_test.go" "tests/preload_test.go"

# Remove all other test files in tests/ and schema/ except the ones we need
cd tests
for f in *_test.go; do
  if [ "$f" != "preload_test.go" ] && [ "$f" != "tests_test.go" ] && [ "$f" != "helper_test.go" ] && [ "$f" != "sql_builder_test.go" ] && [ "$f" != "scopes_test.go" ]; then
    rm -f "$f"
  fi
done
cd ..

cd schema
for f in *_test.go; do
  if [ "$f" != "relationship_test.go" ] && [ "$f" != "schema_helper_test.go" ] && [ "$f" != "model_test.go" ]; then
    rm -f "$f"
  fi
done
cd ..

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
# The -mod=mod flag allows go to modify go.mod/go.sum as needed
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run tests in schema/ and tests/ directories
cd /app/gorm/schema && go test -mod=mod -v .
schema_status=$?

cd /app/gorm/tests && go test -mod=mod -v .
tests_status=$?

# Overall test status
if [ $schema_status -eq 0 ] && [ $tests_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
