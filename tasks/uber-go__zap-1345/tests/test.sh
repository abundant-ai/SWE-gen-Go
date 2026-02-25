#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "benchmarks"
cp "/tests/benchmarks/scenario_bench_test.go" "benchmarks/scenario_bench_test.go"
mkdir -p "."
cp "/tests/encoder_test.go" "encoder_test.go"
mkdir -p "."
cp "/tests/error_test.go" "error_test.go"
mkdir -p "."
cp "/tests/http_handler_test.go" "http_handler_test.go"
mkdir -p "."
cp "/tests/stacktrace_ext_test.go" "stacktrace_ext_test.go"
mkdir -p "."
cp "/tests/writer_test.go" "writer_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/buffered_write_syncer_bench_test.go" "zapcore/buffered_write_syncer_bench_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/buffered_write_syncer_test.go" "zapcore/buffered_write_syncer_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/core_test.go" "zapcore/core_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/encoder_test.go" "zapcore/encoder_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/entry_ext_test.go" "zapcore/entry_ext_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/error_test.go" "zapcore/error_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/json_encoder_bench_test.go" "zapcore/json_encoder_bench_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/json_encoder_impl_test.go" "zapcore/json_encoder_impl_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/level_test.go" "zapcore/level_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/memory_encoder_test.go" "zapcore/memory_encoder_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/tee_test.go" "zapcore/tee_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/write_syncer_bench_test.go" "zapcore/write_syncer_bench_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/write_syncer_test.go" "zapcore/write_syncer_test.go"
mkdir -p "zaptest/observer"
cp "/tests/zaptest/observer/observer_test.go" "zaptest/observer/observer_test.go"

# Run tests for the packages containing the PR test files
overall_status=0

# Main package tests (encoder_test.go, error_test.go, http_handler_test.go, stacktrace_ext_test.go, writer_test.go)
go test -v . || overall_status=1

# Benchmarks package (separate module, need to cd into it)
(cd benchmarks && go test -v .) || overall_status=1

# zapcore package tests
go test -v ./zapcore || overall_status=1

# zaptest/observer package tests
go test -v ./zaptest/observer || overall_status=1

if [ $overall_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$overall_status"
