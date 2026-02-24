#!/bin/bash

cd /app/src

export GOPATH=/go
export PATH="${GOPATH}/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "doc"
cp "/tests/doc/man_docs_test.go" "doc/man_docs_test.go"
mkdir -p "doc"
cp "/tests/doc/md_docs_test.go" "doc/md_docs_test.go"
mkdir -p "doc"
cp "/tests/doc/rest_docs_test.go" "doc/rest_docs_test.go"

# Run tests from the specific test files modified in this PR
go test -v ./doc
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
