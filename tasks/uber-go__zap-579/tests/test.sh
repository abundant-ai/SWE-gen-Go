#!/bin/bash

# Use GOPATH mode and correct directory
export GO111MODULE=off
export GOPATH=/go
cd /go/src/go.uber.org/zap

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/array_test.go" "array_test.go"
mkdir -p "benchmarks"
cp "/tests/benchmarks/zap_test.go" "benchmarks/zap_test.go"
mkdir -p "."
cp "/tests/error_test.go" "error_test.go"
mkdir -p "."
cp "/tests/field_test.go" "field_test.go"
mkdir -p "."
cp "/tests/global_test.go" "global_test.go"
mkdir -p "."
cp "/tests/logger_bench_test.go" "logger_bench_test.go"
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"
mkdir -p "."
cp "/tests/sugar_test.go" "sugar_test.go"

# Run tests from modified files only
# Tests for PR #579 - run all tests from the 8 modified test files
go test -v -run "TestArrayWrappers|TestErrorConstructors|TestErrorArrayConstructor|TestErrorsArraysHandleRichErrors|TestFieldConstructors|TestStackField|TestReplaceGlobals|TestGlobalsConcurrentUse|TestNewStdLog|TestNewStdLogAt|TestNewStdLogAtPanics|TestNewStdLogAtFatal|TestNewStdLogAtInvalid|TestRedirectStdLog|TestRedirectStdLogCaller|TestRedirectStdLogAt|TestRedirectStdLogAtCaller|TestRedirectStdLogAtPanics|TestRedirectStdLogAtFatal|TestRedirectStdLogAtInvalid|TestLoggerAtomicLevel|TestLoggerInitialFields|TestLoggerWith|TestLoggerLogPanic|TestLoggerLogFatal|TestLoggerLeveledMethods|TestLoggerAlwaysPanics|TestLoggerAlwaysFatals|TestLoggerDPanic|TestLoggerNoOpsDisabledLevels|TestLoggerNames|TestLoggerWriteFailure|TestLoggerSync|TestLoggerSyncFail|TestLoggerAddCaller|TestLoggerAddCallerFail|TestLoggerReplaceCore|TestLoggerHooks|TestLoggerConcurrent|TestSugarWith|TestSugarFieldsInvalidPairs|TestSugarStructuredLogging|TestSugarConcatenatingLogging|TestSugarTemplatedLogging|TestSugarPanicLogging|TestSugarFatalLogging|TestSugarAddCaller|TestSugarAddCallerFail" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
