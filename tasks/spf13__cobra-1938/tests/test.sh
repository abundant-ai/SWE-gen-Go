#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/completions_test.go" "completions_test.go"

# Run all tests from completions_test.go
# This PR removes code and tests, so we need to verify all remaining tests pass
# We run tests at the current directory (.) which is the main package
go test -v -run '^Test(CmdNameCompletionInGo|NoCmdNameCompletionInGo|ValidArgsCompletionInGo|ValidArgsAndCmdCompletionInGo|ValidArgsFuncAndCmdCompletionInGo|FlagNameCompletionInGo|FlagNameCompletionInGoWithDesc|FlagNameCompletionRepeat|RequiredFlagNameCompletionInGo|FlagFileExtFilterCompletionInGo|FlagDirFilterCompletionInGo|ValidArgsFuncCmdContext|ValidArgsFuncSingleCmd|ValidArgsFuncSingleCmdInvalidArg|ValidArgsFuncChildCmds|ValidArgsFuncAliases|ValidArgsFuncInBashScript|NoValidArgsFuncInBashScript|CompleteCmdInBashScript|CompleteNoDesCmdInZshScript|CompleteCmdInZshScript|FlagCompletionInGo|ValidArgsFuncChildCmdsWithDesc|FlagCompletionWithNotInterspersedArgs|FlagCompletionWorksRootCommandAddedAfterFlags|FlagCompletionForPersistentFlagsCalledFromSubCmd|FlagCompletionConcurrentRegistration|FlagCompletionInGoWithDesc|ValidArgsNotValidArgsFunc|ArgAliasesCompletionInGo|CompleteHelp|DefaultCompletionCmd|CompleteCompletion|MultipleShorthandFlagCompletion|CompleteWithDisableFlagParsing|CompleteWithRootAndLegacyArgs|FixedCompletions|CompletionForGroupedFlags|CompletionForOneRequiredGroupFlags|CompletionForMutuallyExclusiveFlags|CompletionCobraFlags|ArgsNotDetectedAsFlagsCompletionInGo|GetFlagCompletion)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
