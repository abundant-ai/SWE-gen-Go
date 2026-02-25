#!/bin/bash

# Disable Go modules for pre-module Go testing
export GO111MODULE=off
export GOPATH=/tmp/gopath
mkdir -p $GOPATH/src/github.com/stretchr
ln -sf /app/src $GOPATH/src/github.com/stretchr/testify

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "assert"
cp "/tests/assert/forward_assertions_test.go" "assert/forward_assertions_test.go"
mkdir -p "suite"
cp "/tests/suite/suite_test.go" "suite/suite_test.go"

# Run tests for forward_assertions in the assert package
cd $GOPATH/src/github.com/stretchr/testify
go test -v -run "^Test.*Wrapper$" github.com/stretchr/testify/assert
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
