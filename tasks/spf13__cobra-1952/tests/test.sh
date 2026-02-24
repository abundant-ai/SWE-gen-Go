#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/completions_test.go" "completions_test.go"
mkdir -p "."
cp "/tests/flag_groups_test.go" "flag_groups_test.go"

# Run tests from completions_test.go and flag_groups_test.go using -run regex pattern
go test -v -run '^Test(CmdNameCompletionInGo|NoCmdNameCompletionInGo|ValidArgsCompletionInGo|ValidArgsAndCmdCompletionInGo|ValidArgsFuncAndCmdCompletionInGo|FlagNameCompletionInGo|FlagNameCompletionInGoWithDesc|FlagNameCompletionRepeat|RequiredFlagNameCompletionInGo|FlagFileExtFilterCompletionInGo|FlagDirFilterCompletionInGo|ValidArgsFuncCmdContext|ValidArgsFuncSingleCmd|ValidArgsFuncSingleCmdInvalidArg|ValidArgsFuncChildCmds|ValidArgsFuncAliases|ValidArgsFuncInBashScript|NoValidArgsFuncInBashScript|CompleteCmdInBashScript|CompleteNoDesCmdInZshScript|CompleteCmdInZshScript|FlagCompletionInGo|ValidArgsFuncChildCmdsWithDesc|FlagCompletionWithNotInterspersedArgs|FlagCompletionWorksRootCommandAddedAfterFlags|FlagCompletionInGoWithDesc|ValidArgsNotValidArgsFunc|ArgAliasesCompletionInGo|CompleteHelp|DefaultCompletionCmd|CompleteCompletion|MultipleShorthandFlagCompletion|CompleteWithDisableFlagParsing|CompleteWithRootAndLegacyArgs|FixedCompletions|CompletionForGroupedFlags|CompletionForOneRequiredGroupFlags|CompletionForMutuallyExclusiveFlags|CompletionCobraFlags|ArgsNotDetectedAsFlagsCompletionInGo|ValidateFlagGroups)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
