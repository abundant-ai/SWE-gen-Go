#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/schema/naming_test.go" "schema/naming_test.go"
cp "/tests/schema/relationship_test.go" "schema/relationship_test.go"
cp "/tests/error_translator_test.go" "tests/error_translator_test.go"
cp "/tests/transaction_test.go" "tests/transaction_test.go"
cp "/tests/update_test.go" "tests/update_test.go"

# Remove other test files in schema/ that are not part of this PR
# Keep schema_helper_test.go (helper functions) and model_test.go (User type definition)
rm -f schema/callbacks_test.go schema/check_test.go schema/field_test.go \
      schema/index_test.go \
      schema/schema_test.go schema/utils_test.go

# Remove all other test files in tests/ except the ones we need
# Keep: error_translator_test.go, transaction_test.go, update_test.go
#       tests_test.go (package setup), helper_test.go (test helpers)
cd tests
for f in *_test.go; do
  if [ "$f" != "error_translator_test.go" ] && [ "$f" != "transaction_test.go" ] && [ "$f" != "update_test.go" ] && [ "$f" != "tests_test.go" ] && [ "$f" != "helper_test.go" ]; then
    rm -f "$f"
  fi
done
cd ..

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
# The -mod=mod flag allows go to modify go.mod/go.sum as needed
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run tests in schema/ directory (only naming_test.go and relationship_test.go remain)
cd schema && go test -mod=mod -v .
schema_status=$?

# Run tests in tests/ directory (only the 3 specific test files)
cd /app/gorm/tests && go test -mod=mod -v .
tests_status=$?

# Overall status is successful if both passed
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
