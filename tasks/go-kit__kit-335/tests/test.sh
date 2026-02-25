#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "auth/jwt"
cp "/tests/auth/jwt/middleware_test.go" "auth/jwt/middleware_test.go"
cp "/tests/auth/jwt/transport_test.go" "auth/jwt/transport_test.go"

# Run the specific tests for the auth/jwt package
go test -v ./auth/jwt -run "Test" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
