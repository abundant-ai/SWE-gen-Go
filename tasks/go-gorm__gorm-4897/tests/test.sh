#!/bin/bash

cd /app/src

# Start PostgreSQL
service postgresql start

# Wait for PostgreSQL to be ready
for i in {1..30}; do
    if su - postgres -c "psql -c 'SELECT 1;'" &>/dev/null; then
        break
    fi
    sleep 1
done

# Set up PostgreSQL database and user
su - postgres -c "psql -c \"CREATE USER gorm WITH PASSWORD 'gorm';\""
su - postgres -c "psql -c \"CREATE DATABASE gorm OWNER gorm;\""
su - postgres -c "psql -d gorm -c \"GRANT ALL PRIVILEGES ON DATABASE gorm TO gorm;\""

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
cp "/tests/go.mod" "tests/go.mod"
cp "/tests/update_test.go" "tests/update_test.go"

# Clean Go module cache, tidy, and download dependencies after updating test files
go clean -modcache
cd /app/src/tests
rm -f go.sum
go mod tidy
go mod download

# Run the specific tests from update_test.go with postgres
export GORM_DIALECT=postgres
export GORM_DSN="user=gorm password=gorm dbname=gorm host=localhost port=5432 sslmode=disable TimeZone=Asia/Shanghai"
cd /app/src/tests && go test -mod=mod -v -run '^(TestUpdate|TestUpdates|TestUpdateColumn|TestBlockGlobalUpdate|TestSelectWithUpdate|TestSelectWithUpdateWithMap|TestWithUpdateWithInvalidMap|TestOmitWithUpdate|TestOmitWithUpdateWithMap|TestSelectWithUpdateColumn|TestOmitWithUpdateColumn|TestUpdateColumnsSkipsAssociations|TestUpdatesWithBlankValues|TestUpdatesTableWithIgnoredValues|TestUpdateFromSubQuery|TestSave|TestSaveWithPrimaryValue|TestUpdateReturning)$'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
