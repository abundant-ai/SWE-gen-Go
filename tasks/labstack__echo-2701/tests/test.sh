#!/bin/bash

cd /app/src

# This PR removes the JWT middleware and its tests
# Verify that the JWT middleware implementation is removed
if [ -f "middleware/jwt.go" ]; then
  echo "FAIL: JWT middleware file still exists" >&2
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Verify that the JWT dependency is removed from go.mod
if grep -q "github.com/golang-jwt/jwt" go.mod; then
  echo "FAIL: JWT dependency still present in go.mod" >&2
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Verify the project builds successfully
go build ./...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
