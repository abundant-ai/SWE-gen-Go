#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "hooks/syslog"
cp "/tests/hooks/syslog/syslog_test.go" "hooks/syslog/syslog_test.go"
mkdir -p "hooks/test"
cp "/tests/hooks/test/test.go" "hooks/test/test.go"
mkdir -p "hooks/test"
cp "/tests/hooks/test/test_test.go" "hooks/test/test_test.go"

# Clean up any problematic tool files in dependencies (they conflict with the unix package)
find /go/src/golang.org/x/sys/unix -name "mk*.go" -delete 2>/dev/null || true

# Run the specific test files with race detector
go test -v -race ./hooks/syslog ./hooks/test 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
