#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/gomigrations/register"
cp "/tests/gomigrations/register/register_test.go" "tests/gomigrations/register/register_test.go"
mkdir -p "tests/gomigrations/register/testdata"
cp "/tests/gomigrations/register/testdata/001_addmigration.go" "tests/gomigrations/register/testdata/001_addmigration.go"
mkdir -p "tests/gomigrations/register/testdata"
cp "/tests/gomigrations/register/testdata/002_addmigrationnotx.go" "tests/gomigrations/register/testdata/002_addmigrationnotx.go"
mkdir -p "tests/gomigrations/register/testdata"
cp "/tests/gomigrations/register/testdata/003_addmigrationcontext.go" "tests/gomigrations/register/testdata/003_addmigrationcontext.go"
mkdir -p "tests/gomigrations/register/testdata"
cp "/tests/gomigrations/register/testdata/004_addmigrationnotxcontext.go" "tests/gomigrations/register/testdata/004_addmigrationnotxcontext.go"

# Run tests for the specific package touched by this PR
# Use -short flag to skip tests that require Docker
go test -v -short ./tests/gomigrations/register/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
