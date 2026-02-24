#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# This is a library package with no test files in a separate module
# For Oracle: the agent will have applied the fix to the source
# For NOP: the source remains in BASE (buggy) state
# We verify the code uses net.JoinHostPort (IPv6-safe) instead of fmt.Sprintf
test_status=0
cd test/integration/consul-container || exit 1

# Check if the fixed code uses net.JoinHostPort for proper IPv6 formatting
if ! grep -q "net.JoinHostPort" libs/assert/service.go; then
	echo "FAIL: service.go should use net.JoinHostPort for IPv6-safe address formatting" >&2
	test_status=1
fi

# Check that it doesn't use the broken fmt.Sprintf pattern
if grep -q 'fmt.Sprintf("%s:%d"' libs/assert/service.go; then
	echo "FAIL: service.go should not use fmt.Sprintf for address formatting (not IPv6-safe)" >&2
	test_status=1
fi

# Verify the package compiles
go build ./libs/assert || test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
