#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/resolver/dns"
cp "/tests/internal/resolver/dns/dns_resolver_test.go" "internal/resolver/dns/dns_resolver_test.go"

# Run the specific test package for this PR
# Test file is in: internal/resolver/dns/
go test -v -timeout 7m ./internal/resolver/dns/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
