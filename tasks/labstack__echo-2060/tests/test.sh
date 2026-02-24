#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/csrf_test.go" "middleware/csrf_test.go"
mkdir -p "middleware"
cp "/tests/middleware/extractor_test.go" "middleware/extractor_test.go"
mkdir -p "middleware"
cp "/tests/middleware/jwt_test.go" "middleware/jwt_test.go"
mkdir -p "middleware"
cp "/tests/middleware/key_auth_test.go" "middleware/key_auth_test.go"

# Run Go tests for the specific test files in middleware package
go test -v ./middleware -run "TestCSRF|TestValuesFrom|TestCreateExtractors|TestJWT|TestKeyAuth"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
