#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
# No test files to copy for this PR

# Verify the build succeeds and the grpchttp2 package is removed
test_status=0

# Check that the grpchttp2 package files no longer exist (directory may remain but be empty)
if [ -f "internal/transport/grpchttp2/errors.go" ] || [ -f "internal/transport/grpchttp2/framer.go" ] || [ -f "internal/transport/grpchttp2/http2bridge.go" ]; then
  echo "FAIL: grpchttp2 package files still exist after fix"
  test_status=1
fi

# Verify the transport package builds successfully (only packages that exist in HEAD)
go build ./internal/transport || test_status=1
go build ./internal/transport/networktype || test_status=1

# Run transport tests to ensure no regressions (only packages that exist in HEAD)
go test -v -timeout 7m ./internal/transport || test_status=1
go test -v -timeout 7m ./internal/transport/networktype || test_status=1

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
