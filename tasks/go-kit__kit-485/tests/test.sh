#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log/term"
cp "/tests/log/term/terminal_windows_test.go" "log/term/terminal_windows_test.go"

# This is Windows-specific code. Cross-compile for Windows to check if it builds.
# In BASE state, the test file calls IsConsole() which doesn't exist, causing a build failure.
# In HEAD state (Oracle), IsConsole() exists and the build succeeds.
GOOS=windows GOARCH=amd64 go test -c ./log/term 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
