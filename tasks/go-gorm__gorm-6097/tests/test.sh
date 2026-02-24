#!/bin/bash

cd /app/gorm

# Add ErrSubQueryRequired constant to make tests compile (minimal change needed for test compilation)
# This is added in the fix, but we need it for the HEAD test to compile against BASE code
# Only add it if it doesn't already exist (Oracle applies fix first, which includes this)
if ! grep -q "ErrSubQueryRequired" errors.go; then
  sed -i '/ErrModelAccessibleFieldsRequired = errors.New("model accessible fields required")/a\	// ErrSubQueryRequired sub query required\n\tErrSubQueryRequired = errors.New("sub query required")' errors.go
fi

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/migrate_test.go" "tests/migrate_test.go"

# Remove all other test files in tests/ except the ones we need
cd tests
for f in *_test.go; do
  if [ "$f" != "migrate_test.go" ] && [ "$f" != "tests_test.go" ] && [ "$f" != "helper_test.go" ] && [ "$f" != "sql_builder_test.go" ] && [ "$f" != "scopes_test.go" ] && [ "$f" != "tracer_test.go" ]; then
    rm -f "$f"
  fi
done
cd ..

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
# The -mod=mod flag allows go to modify go.mod/go.sum as needed
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run tests in tests/ directory
cd /app/gorm/tests && go test -mod=mod -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
