#!/bin/bash

cd /app/src

# Initialize and start MySQL for multi-primary key testing
mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql 2>&1 | head -20
mysqld --user=mysql --datadir=/var/lib/mysql --sql-mode="NO_ENGINE_SUBSTITUTION" &
sleep 5

# Create test database and user
mysql -u root -e "CREATE DATABASE gorm;"
mysql -u root -e "CREATE USER 'gorm'@'localhost' IDENTIFIED BY 'gorm';"
mysql -u root -e "GRANT ALL PRIVILEGES ON gorm.* TO 'gorm'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root -e "SET GLOBAL sql_mode='NO_ENGINE_SUBSTITUTION';"

# Use mysql dialect to properly test multi-primary keys
export GORM_DIALECT=mysql

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/multi_primary_keys_test.go" "multi_primary_keys_test.go"

# Remove mssql driver import from main_test.go which has complex dependencies
sed -i '/github.com\/denisenkom\/go-mssqldb/d' main_test.go

# Run the specific tests from multi_primary_keys_test.go
go test -v -run '^(TestManyToManyWithMultiPrimaryKeys|TestManyToManyWithCustomizedForeignKeys|TestManyToManyWithCustomizedForeignKeys2)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
