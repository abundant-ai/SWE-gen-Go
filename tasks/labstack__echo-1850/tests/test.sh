#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/echo_test.go" "echo_test.go"
mkdir -p "middleware"
cp "/tests/middleware/csrf_test.go" "middleware/csrf_test.go"
mkdir -p "middleware"
cp "/tests/middleware/proxy_test.go" "middleware/proxy_test.go"
mkdir -p "middleware"
cp "/tests/middleware/timeout_test.go" "middleware/timeout_test.go"

# Remove version-specific test files only if the corresponding source files don't exist
# This indicates fix.patch was applied (Oracle agent), which removes source files but not test files
# For NOP agent (BASE state), source files exist, so we keep test files to cause build failures
if [ ! -f "middleware/csrf_samesite.go" ]; then
    rm -f echo_go1.13_test.go
    rm -f middleware/csrf_samesite_test.go
    rm -f middleware/proxy_1_11_test.go
fi

# Run Go tests for the specific test files from this PR
# For echo_test.go, run tests in the current package
go test -v -run "TestEcho" && \
go test -v ./middleware -run "^(TestCSRF|TestProxy|TestTimeout)"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
