#!/bin/bash

cd /app/src

# Initialize and start PostgreSQL for database testing
su - postgres -c "/usr/lib/postgresql/*/bin/initdb -D /var/lib/postgresql/data" 2>&1 | head -20
su - postgres -c "/usr/lib/postgresql/*/bin/pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/logfile start"
sleep 3

# Create test database and user
su - postgres -c "psql -c \"CREATE USER gorm WITH PASSWORD 'gorm';\""
su - postgres -c "psql -c \"CREATE DATABASE gorm OWNER gorm;\""
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE gorm TO gorm;\""

# Use postgres dialect for tests
export GORM_DIALECT=postgres

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/main_test.go" "main_test.go"

# Remove mssql driver import from main_test.go which has complex dependencies
sed -i '/github.com\/denisenkom\/go-mssqldb/d' main_test.go

# Run only the TestCreate test which is specific to this PR
go test -v -run TestCreate$ .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
