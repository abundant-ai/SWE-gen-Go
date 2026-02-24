#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/echo_test.go" "echo_test.go"
mkdir -p "."
cp "/tests/group_test.go" "group_test.go"
mkdir -p "."
cp "/tests/router_test.go" "router_test.go"

# Run Go tests for the specific test files that contain RouteNotFound functionality tests
go test -v -run "TestGroup_RouteNotFound|TestEchoRouteNotFound|TestRouteNotFoundPriority"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
