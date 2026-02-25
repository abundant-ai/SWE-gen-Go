#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/admin-handlers_test.go" "cmd/admin-handlers_test.go"
mkdir -p "cmd"
cp "/tests/cmd/local-locker_test.go" "cmd/local-locker_test.go"
mkdir -p "cmd"
cp "/tests/cmd/lock-rest-server-common_test.go" "cmd/lock-rest-server-common_test.go"
mkdir -p "cmd"
cp "/tests/cmd/object-api-utils_test.go" "cmd/object-api-utils_test.go"

# Run specific tests from the modified test files
# Using -run regex to match only tests in the modified files
go test -v -timeout 10m -run "^(TestServiceRestartHandler|TestAdminServerInfo|TestToAdminAPIErrCode|TestExtractHealInitParams|TestTopLockEntries|TestLocalLockerExpire|TestLocalLockerUnlock|Test_localLocker_expireOldLocksExpire|Test_localLocker_RUnlock|TestLockRpcServerRemoveEntry|TestPathTraversalExploit|TestIsValidBucketName|TestIsValidObjectName|TestGetCompleteMultipartMD5|TestIsMinioMetaBucketName|TestRemoveStandardStorageClass|TestCleanMetadata|TestCleanMetadataKeys|TestIsCompressed|TestExcludeForCompression)$" ./cmd
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
