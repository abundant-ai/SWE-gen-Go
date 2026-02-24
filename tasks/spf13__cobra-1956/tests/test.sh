#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/cobra_test.go" "cobra_test.go"
mkdir -p "."
cp "/tests/command_test.go" "command_test.go"

# Run tests from cobra_test.go and command_test.go using -run regex pattern
go test -v -run '^Test(AddTemplateFunctions|LevenshteinDistance|StringInSlice|Rpad|DeadcodeElimination|SingleCommand|ChildCommand|CallCommandWithoutSubcommands|RootExecuteUnknownCommand|SubcommandExecuteC|ExecuteContext|ExecuteContextC|Execute_NoContext|RootUnknownCommandSilenced|CommandAlias|EnablePrefixMatching|AliasPrefixMatching|Plugin|PluginWithSubCommands|ChildSameName|GrandChildSameName|FlagLong|FlagShort|ChildFlag|ChildFlagWithParentLocalFlag|FlagInvalidInput|FlagBeforeCommand|StripFlags|DisableFlagParsing|PersistentFlagsOnSameCommand|EmptyInputs|ChildFlagShadowsParentPersistentFlag|PersistentFlagsOnChild|RequiredFlags|PersistentRequiredFlags)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
