#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/checks"
cp "/tests/agent/checks/check_test.go" "agent/checks/check_test.go"
mkdir -p "agent"
cp "/tests/agent/http_test.go" "agent/http_test.go"
mkdir -p "agent"
cp "/tests/agent/kvs_endpoint_test.go" "agent/kvs_endpoint_test.go"
mkdir -p "api"
cp "/tests/api/api_test.go" "api/api_test.go"

# Run the specific tests for the PR
# agent/checks package: TestCheckHTTPBody and TestCheck_Docker tests (modified in bug.patch)
# agent package: TestHTTPAPIResponseHeaders, TestHTTPAPIValidateContentTypeHeaders, TestErrorContentTypeHeaderSet, TestKVSEndpoint_GET_Raw
# api package: TestAPI_Headers
go test -v -timeout=2m ./agent/checks -run "TestCheckHTTPBody|TestCheck_Docker"
test_status_checks=$?

go test -v -timeout=2m ./agent -run "TestHTTPAPIResponseHeaders|TestHTTPAPIValidateContentTypeHeaders|TestErrorContentTypeHeaderSet|TestKVSEndpoint_GET_Raw"
test_status_agent=$?

go test -v -timeout=2m github.com/hashicorp/consul/api -run "TestAPI_Headers"
test_status_api=$?

# Combine exit codes: if any test failed, overall status is failure
test_status=0
if [ $test_status_checks -ne 0 ] || [ $test_status_agent -ne 0 ] || [ $test_status_api -ne 0 ]; then
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
