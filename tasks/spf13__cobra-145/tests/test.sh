#!/bin/bash

cd /app/src

export GOPATH=/go
export PATH="/usr/local/go/bin:${GOPATH}/bin:/usr/bin:/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/cobra_test.go" "cobra_test.go"
mkdir -p "."
cp "/tests/examples_test.go" "examples_test.go"
mkdir -p "."
cp "/tests/man_docs_test.go" "man_docs_test.go"

# Run tests from the specific test files modified in this PR
# We run the example functions and TestGenManDoc test
go test -v -run="ExampleCommand_GenManTree|ExampleCommand_GenMan|TestGenManDoc" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
