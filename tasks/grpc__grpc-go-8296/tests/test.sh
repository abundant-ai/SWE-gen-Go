#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/resolver/delegatingresolver"
cp "/tests/internal/resolver/delegatingresolver/delegatingresolver_ext_test.go" "internal/resolver/delegatingresolver/delegatingresolver_ext_test.go"
mkdir -p "internal/transport"
cp "/tests/internal/transport/http_util_test.go" "internal/transport/http_util_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/resolver/delegatingresolver/... ./internal/transport/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
