#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/echo_test.go" "echo_test.go"
mkdir -p "."
cp "/tests/router_test.go" "router_test.go"

# Run Go tests for the specific test functions that were added/modified in this PR
# These tests validate the OnAddRouteHandler functionality and router improvements
go test -v -run "^(TestEcho_OnAddRouteHandler|TestEchoRoutesHandleAdditionalHosts|TestEchoRoutesHandleHostsProperly|TestEchoRoutesHandleDefaultHost|TestEchoReverseHandleHostProperly|TestRouter_Routes|TestRouter_Reverse)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
