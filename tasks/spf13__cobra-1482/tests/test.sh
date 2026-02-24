#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/active_help_test.go" "active_help_test.go"
mkdir -p "."
cp "/tests/bash_completionsV2_test.go" "bash_completionsV2_test.go"
mkdir -p "."
cp "/tests/bash_completions_test.go" "bash_completions_test.go"
mkdir -p "."
cp "/tests/fish_completions_test.go" "fish_completions_test.go"
mkdir -p "."
cp "/tests/power_completions_test.go" "power_completions_test.go"
mkdir -p "."
cp "/tests/zsh_completions_test.go" "zsh_completions_test.go"

# Run tests from the specific test files modified in this PR
# Use -run to target test functions from these files
go test -v -run "^Test(ActiveHelp|BashCompletions|FishCompletions|PowerShellCompletions|Zsh)" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
