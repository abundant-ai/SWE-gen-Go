#!/bin/bash

cd /app/src

export GOPATH=/go
export PATH="/usr/local/go/bin:${GOPATH}/bin:/usr/bin:/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/bash_completions_test.go" "bash_completions_test.go"
mkdir -p "."
cp "/tests/cobra_test.go" "cobra_test.go"
mkdir -p "."
cp "/tests/md_docs_test.go" "md_docs_test.go"

# Run tests for the Deprecated feature added in this PR
go test -v -run="TestDeprecatedSub|TestBashCompletions|TestGenMdDoc" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
