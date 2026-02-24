#!/bin/bash

cd /app/src

export GOPATH=/go
export PATH="/usr/local/go/bin:${GOPATH}/bin:/usr/bin:/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/cobra_test.go" "cobra_test.go"

# Run tests from the specific test files modified in this PR
# Skip tests that call Execute() directly as they conflict with go test flags
go test -v -run="TestSingleCommand|TestChildCommand|TestCommandAlias|TestPrefixMatching|TestNoPrefixMatching|TestAliasPrefixMatching|TestChildSameName|TestGrandChildSameName|TestFlagLong|TestFlagShort|TestChildCommandFlags|TestTrailingCommandFlags|TestInvalidSubcommandFlags|TestSubcommandArgEvaluation|TestPersistentFlags|TestHelpCommand|TestChildCommandHelp|TestNonRunChildHelp|TestRunnableRootCommand$|TestRunnableRootCommandEmptyInput|TestInvalidSubcommandWhenArgsAllowed|TestRootFlags|TestRootHelp|TestFlagAccess|TestNoNRunnableRootCommandNilInput|TestRootNoCommandHelp|TestRootUnknownCommand|TestRootSuggestions|TestFlagsBeforeCommand|TestRemoveCommand|TestCommandWithoutSubcommands|TestCommandWithoutSubcommandsWithArg|TestReplaceCommandWithRemove|TestDeprecatedSub|TestPreRun|TestPeristentPreRunPropagation|TestGlobalNormFuncPropagation|TestFlagOnPflagCommandLine|TestAddTemplateFunctions|TestBashCompletions|TestGenManDoc|TestGenMdDoc" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
