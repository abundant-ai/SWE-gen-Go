#!/bin/bash

cd /app/src

export GOPATH=/go
export PATH="/usr/local/go/bin:${GOPATH}/bin:/usr/bin:/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/bash_completions_test.go" "bash_completions_test.go"

# Run tests from the specific test files modified in this PR
# Only run the BashCompletions test as it's the one modified in this PR
go test -v -run TestBashCompletions .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
