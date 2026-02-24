#!/bin/bash

cd /app/src

# Set lower file descriptor limits to match historical test expectations
ulimit -n 4096 2>/dev/null || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extraction"
cp "/tests/extraction/discriminator_test.go" "extraction/discriminator_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/registry_test.go" "prometheus/registry_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/signature_test.go" "prometheus/signature_test.go"

# Restore vendor/goautoneg directory (was removed by bug.patch) with source and test files
mkdir -p "vendor/goautoneg"
cp "/go/src/bitbucket.org/ww/goautoneg/"*.go "vendor/goautoneg/"
cp "/tests/vendor/goautoneg/autoneg_test.go" "vendor/goautoneg/autoneg_test.go"

# Copy the updated test to GOPATH location as well
cp "/tests/vendor/goautoneg/autoneg_test.go" "/go/src/bitbucket.org/ww/goautoneg/autoneg_test.go"

# Run tests for the packages affected by this PR
go test -v github.com/prometheus/client_golang/extraction 2>&1
extraction_status=$?

go test -v github.com/prometheus/client_golang/prometheus 2>&1
prometheus_status=$?

go test -v bitbucket.org/ww/goautoneg 2>&1
goautoneg_status=$?

# Overall status: fail if any package failed
test_status=$((extraction_status + prometheus_status + goautoneg_status))

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
