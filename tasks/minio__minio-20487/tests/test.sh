#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/config/dns"
cp "/tests/internal/config/dns/etcd_dns_test.go" "internal/config/dns/etcd_dns_test.go"

# Run tests from the modified test file - using -run to match specific tests
# The modified test file has tests: TestDNSJoin, TestPath, TestUnPath
go test -v -timeout 10m -run "TestDNSJoin|TestPath|TestUnPath" ./internal/config/dns
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
