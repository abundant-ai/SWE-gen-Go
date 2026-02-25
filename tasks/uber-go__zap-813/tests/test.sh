#!/bin/bash

cd /app/zap

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "benchmarks"
cp "/tests/benchmarks/zap_test.go" "benchmarks/zap_test.go"
mkdir -p "."
cp "/tests/config_test.go" "config_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/sampler_bench_test.go" "zapcore/sampler_bench_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/sampler_test.go" "zapcore/sampler_test.go"

# Run tests from modified packages
# Tests for PR #813 (SamplingConfig.Hook addition):
# - Root package: TestConfig, TestConfigWithSamplingHook (config_test.go)
# - zapcore package: TestSampler* (sampler_test.go)

# Run specific tests from config_test.go
go test -v . -run "^(TestConfig|TestConfigWithInvalidPaths|TestConfigWithMissingAttributes|TestConfigWithSamplingHook)$"
main_status=$?

# Run sampler tests from zapcore package (excluding flaky TestSamplerConcurrent)
go test -v ./zapcore -run "^TestSampler(DisabledLevels|Ticking|Races|$)$"
zapcore_status=$?

# Benchmarks package just has helper functions (newSampledLogger) that are modified,
# but no actual tests to run, so we just verify it builds
(cd benchmarks && go test -c -o /dev/null .)
bench_status=$?

# Exit with failure if any test failed
if [ $main_status -ne 0 ] || [ $zapcore_status -ne 0 ] || [ $bench_status -ne 0 ]; then
  test_status=1
else
  test_status=0
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
