#!/bin/bash

cd /app/src

# Set GOFLAGS to match CI environment
export GOFLAGS="-mod=readonly"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "auth/jwt"
cp "/tests/auth/jwt/middleware_test.go" "auth/jwt/middleware_test.go"

# Run the specific test files for this PR
go test -v ./auth/jwt
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
