#!/bin/bash

cd /app/src

# Copy HEAD version of commands_test.go (overwrites BASE state)
# Note: bench_decode_test.go is not copied because it references DisableIndentity field
# which doesn't exist in BASE code, causing compilation errors
mkdir -p "."
cp "/tests/commands_test.go" "commands_test.go"

# Run only the ACL LOG test using Ginkgo focus
# This test validates that the CLIENT SETINFO fix reduces ACL log entries from 4 to 3
go test -v -run 'TestGinkgoSuite' . -args -ginkgo.focus='should ACL LOG$'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
