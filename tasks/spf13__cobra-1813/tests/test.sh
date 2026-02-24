#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/completions_test.go" "completions_test.go"

# Run all tests from completions_test.go
# We run tests at the current directory (.) which is the main package
go test -v -run '^(TestCmdNameCompletionInGo|TestNoCmdNameCompletionInGo|TestValidArgsCompletionInGo|TestValidArgsAndCmdCompletionInGo|TestValidArgsFuncAndCmdCompletionInGo|TestFlagNameCompletionInGo|TestFlagNameCompletionInGoWithDesc|TestFlagNameCompletionRepeat|TestRequiredFlagNameCompletionInGo|TestFlagFileExtFilterCompletionInGo|TestFlagDirFilterCompletionInGo|TestValidArgsFuncCmdContext|TestValidArgsFuncSingleCmd|TestValidArgsFuncSingleCmdInvalidArg|TestValidArgsFuncChildCmds|TestValidArgsFuncAliases|TestValidArgsFuncInBashScript|TestNoValidArgsFuncInBashScript|TestCompleteCmdInBashScript|TestCompleteNoDesCmdInZshScript|TestCompleteCmdInZshScript|TestFlagCompletionInGo|TestValidArgsFuncChildCmdsWithDesc|TestFlagCompletionWithNotInterspersedArgs|TestFlagCompletionWorksRootCommandAddedAfterFlags|TestFlagCompletionInGoWithDesc|TestValidArgsNotValidArgsFunc|TestArgAliasesCompletionInGo|TestCompleteHelp|TestDefaultCompletionCmd|TestCompleteCompletion|TestMultipleShorthandFlagCompletion|TestCompleteWithDisableFlagParsing|TestCompleteWithRootAndLegacyArgs|TestFixedCompletions|TestCompletionForGroupedFlags|TestCompletionForMutuallyExclusiveFlags|TestCompletionCobraFlags)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
