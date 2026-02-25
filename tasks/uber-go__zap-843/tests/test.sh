#!/bin/bash

cd /app/zap

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/config_test.go" "config_test.go"
cp "/tests/field_test.go" "field_test.go"
cp "/tests/stacktrace_ext_test.go" "stacktrace_ext_test.go"
cp "/tests/stacktrace_test.go" "stacktrace_test.go"

# Run specific tests related to PR #843 (stacktrace filtering improvements)
# Tests are in the root package, run tests from modified test files
# Note: We exclude TestStackSkipField and TestStackSkipFieldWithSkip tests because
# those test the StackSkip function which is removed in the buggy state but exists in HEAD
# When we copy HEAD test files, those tests exist but will be skipped by the run filter
go test -v . -run "^(TestConfig|TestStackField|TestTakeStacktrace|TestIsZapFrame|TestStacktraceFiltersZapLog|TestStacktraceFiltersVendorZap)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
