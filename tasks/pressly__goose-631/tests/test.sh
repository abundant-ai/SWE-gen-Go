#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/globals_test.go" "globals_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/run_test.go" "internal/provider/run_test.go"
mkdir -p "tests/gomigrations/success"
cp "/tests/gomigrations/success/gomigrations_success_test.go" "tests/gomigrations/success/gomigrations_success_test.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/001_up_down.go" "tests/gomigrations/success/testdata/001_up_down.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/002_up_only.go" "tests/gomigrations/success/testdata/002_up_only.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/003_down_only.go" "tests/gomigrations/success/testdata/003_down_only.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/005_up_down_no_tx.go" "tests/gomigrations/success/testdata/005_up_down_no_tx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/006_up_only_no_tx.go" "tests/gomigrations/success/testdata/006_up_only_no_tx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/007_down_only_no_tx.go" "tests/gomigrations/success/testdata/007_down_only_no_tx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/008_empty_no_tx.go" "tests/gomigrations/success/testdata/008_empty_no_tx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/009_up_down_ctx.go" "tests/gomigrations/success/testdata/009_up_down_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/010_up_only_ctx.go" "tests/gomigrations/success/testdata/010_up_only_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/011_down_only_ctx.go" "tests/gomigrations/success/testdata/011_down_only_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/012_empty_ctx.go" "tests/gomigrations/success/testdata/012_empty_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/013_up_down_no_tx_ctx.go" "tests/gomigrations/success/testdata/013_up_down_no_tx_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/014_up_only_no_tx_ctx.go" "tests/gomigrations/success/testdata/014_up_only_no_tx_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/015_down_only_no_tx_ctx.go" "tests/gomigrations/success/testdata/015_down_only_no_tx_ctx.go"
mkdir -p "tests/gomigrations/success/testdata"
cp "/tests/gomigrations/success/testdata/016_empty_no_tx_ctx.go" "tests/gomigrations/success/testdata/016_empty_no_tx_ctx.go"

# Run tests for the specific test files from this PR
# Test files: globals_test.go, internal/provider/run_test.go, tests/gomigrations/success/gomigrations_success_test.go
# Note: Skip TestLockModeAdvisorySession which requires Docker
go test -v . ./tests/gomigrations/success
test_status=$?
if [ $test_status -ne 0 ]; then
  echo 0 > /logs/verifier/reward.txt
  exit $test_status
fi

# Run internal/provider tests, excluding TestLockModeAdvisorySession (needs Docker)
go test -v -run "^Test(ProviderRun|ConcurrentProvider|NoVersioning|AllowMissing|GoOnly)$" ./internal/provider
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
