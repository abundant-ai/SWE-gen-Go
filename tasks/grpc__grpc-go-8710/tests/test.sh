#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/clientconn_parsed_target_test.go" "clientconn_parsed_target_test.go"
mkdir -p "."
cp "/tests/dial_test.go" "dial_test.go"
mkdir -p "internal/idle"
cp "/tests/internal/idle/idle_e2e_test.go" "internal/idle/idle_e2e_test.go"
mkdir -p "internal/idle"
cp "/tests/internal/idle/idle_test.go" "internal/idle/idle_test.go"
mkdir -p "."
cp "/tests/resolver_balancer_ext_test.go" "resolver_balancer_ext_test.go"
mkdir -p "test"
cp "/tests/clientconn_state_transition_test.go" "test/clientconn_state_transition_test.go"

# Run the specific test packages for this PR
# Test files: clientconn_parsed_target_test.go, dial_test.go, resolver_balancer_ext_test.go (root package)
#             internal/idle/idle_e2e_test.go, internal/idle/idle_test.go (internal/idle package)
#             test/clientconn_state_transition_test.go (test package)
go test -v -timeout 7m . ./internal/idle ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
