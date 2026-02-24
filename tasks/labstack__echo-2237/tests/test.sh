#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/router_test.go" "router_test.go"

# Run Go tests for the specific test functions that were added in this PR
# These tests validate support for arbitrary/custom HTTP methods (like COPY, LOCK, WebDAV methods)
go test -v -run "^(TestRouter_addAndMatchAllSupportedMethods|TestRouterAllowHeaderForAnyOtherMethodType)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
