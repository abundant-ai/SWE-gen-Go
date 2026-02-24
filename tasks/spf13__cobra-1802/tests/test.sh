#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/command_test.go" "command_test.go"

# Run all tests in the package
# The fish_completions_test.go file has a failing test (TestFailGenFishCompletionFile)
# but we need to run all command_test.go tests
# We'll accept that some unrelated tests might fail in the buggy version
go test -v -run "^Test(Single|Child|Call|Root|Subcommand|Execute|Command|Enable|Alias|Grand|Flag|Strip|Disable|Persistent|Empty|Init|Help|Version|Shorthand|Usage|Visit|Suggestions|Case|Remove|Replace|Deprecated|Hooks|Global|Norm|Consistent|OnPflag|Hidden|Commands|Set|Print|Error|Sorted|Merge|UseDeprecated|Traverse|Update|CalledAs|FParseErr|Context)" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
