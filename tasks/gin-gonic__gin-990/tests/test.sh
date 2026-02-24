#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Note: We do NOT copy test files here because bug.patch already modified them
# to the correct BASE state. The test files (context_test.go, errors_test.go) are
# already present in the repo and were updated by bug.patch.

# Run tests from current directory (context_test.go and errors_test.go)
go test -v . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
