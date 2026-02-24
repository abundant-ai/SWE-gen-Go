#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "credentials/tls/certprovider/pemfile"
cp "/tests/credentials/tls/certprovider/pemfile/builder_test.go" "credentials/tls/certprovider/pemfile/builder_test.go"
mkdir -p "internal/xds/bootstrap/tlscreds"
cp "/tests/internal/xds/bootstrap/tlscreds/bundle_ext_test.go" "internal/xds/bootstrap/tlscreds/bundle_ext_test.go"

# Run the specific test packages for this PR
# Test files are in: credentials/tls/certprovider/pemfile/ and internal/xds/bootstrap/tlscreds/
go test -v -timeout 7m ./credentials/tls/certprovider/pemfile/... ./internal/xds/bootstrap/tlscreds/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
