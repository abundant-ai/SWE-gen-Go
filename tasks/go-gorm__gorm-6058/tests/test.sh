#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/clause/select_test.go" "clause/select_test.go"
cp "/tests/connpool_test.go" "tests/connpool_test.go"
cp "/tests/embedded_struct_test.go" "tests/embedded_struct_test.go"
cp "/tests/helper_test.go" "tests/helper_test.go"
cp "/tests/migrate_test.go" "tests/migrate_test.go"
cp "/tests/preload_test.go" "tests/preload_test.go"
cp "/tests/table_test.go" "tests/table_test.go"

# Download compatible test dependencies (v1.4.x versions compatible with this GORM version)
go get gorm.io/driver/sqlite@v1.4.4 gorm.io/driver/mysql@v1.4.5 gorm.io/driver/postgres@v1.4.8 gorm.io/driver/sqlserver@v1.4.2 2>/dev/null || true

# Run specific test files (not entire test suite)
cd /app/gorm/clause && go test -mod=mod -v -run TestSelect .
test_status=$?

if [ $test_status -eq 0 ]; then
  cd /app/gorm/tests && go test -mod=mod -v -run "TestConnPoolWrapper|TestEmbeddedStruct|TestEmbeddedPointerTypeStruct|TestEmbeddedScanValuer|TestEmbeddedRelations|TestEmbeddedTagSetting|TestMigrate|TestAutoMigrateInt8PG|TestAutoMigrateSelfReferential|TestSmartMigrateColumn|TestMigrateWithColumnComment|TestMigrateWithIndexComment|TestMigrateWithUniqueIndex|TestMigrateTable|TestMigrateWithQuotedIndex|TestMigrateIndexes|TestTiDBMigrateColumns|TestMigrateColumns|TestMigrateConstraint|TestMigrateIndexesWithDynamicTableName|TestMigrateColumnOrder|TestMigrateSerialColumn|TestMigrateWithSpecialName|TestPrimarykeyID|TestCurrentTimestamp|TestUniqueColumn|TestInvalidCachedPlanSimpleProtocol|TestInvalidCachedPlanPrepareStmt|TestDifferentTypeWithoutDeclaredLength|TestMigrateArrayTypeModel|TestMigrateDonotAlterColumn|TestMigrateSameEmbeddedFieldName|TestMigrateDefaultNullString|TestMigrateMySQLWithCustomizedTypes|TestMigrateIgnoreRelations|TestPreloadWithAssociations|TestNestedPreloadWithCond|TestNestedPreloadWithUnscoped|TestTableWithNamer|TestTableWithAllFields|TestTable" .
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
