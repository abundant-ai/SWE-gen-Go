#!/bin/bash

# Use GOPATH mode and correct directory
export GO111MODULE=off
export GOPATH=/go
cd /go/src/go.uber.org/zap

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/sink_test.go" "sink_test.go"
mkdir -p "."
cp "/tests/writer_test.go" "writer_test.go"

# Run tests from modified files only - PR #572
go test -v -run "TestRegisterSink|TestNewSink|TestOpenNoPaths|TestOpen|TestOpenFails|TestOpenWithCustomSink|TestOpenWithErroringSinkFactory|TestCombineWriteSyncers" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
