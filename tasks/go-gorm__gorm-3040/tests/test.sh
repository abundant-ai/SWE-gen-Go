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
mkdir -p "."
cp "/tests/statement_test.go" "statement_test.go"

# Clean Go module cache, tidy, and download dependencies after updating test files
rm -f go.sum
go mod tidy
go mod download

# Run the specific tests from statement_test.go with postgres
export GORM_DIALECT=postgres
export GORM_DSN="user=gorm password=gorm dbname=gorm host=localhost port=5432 sslmode=disable TimeZone=Asia/Shanghai"
go test -v -run '^TestWhereCloneCorruption$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
