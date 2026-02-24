#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "credentials/jwt"
cp "/tests/credentials/jwt/file_reader_test.go" "credentials/jwt/file_reader_test.go"
mkdir -p "credentials/jwt"
cp "/tests/credentials/jwt/token_file_call_creds_test.go" "credentials/jwt/token_file_call_creds_test.go"

# Run the specific test package for this PR
go test -v -timeout 7m ./credentials/jwt
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
