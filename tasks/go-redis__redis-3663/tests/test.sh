#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "maintnotifications"
cp "/tests/maintnotifications/push_notification_handler_test.go" "maintnotifications/push_notification_handler_test.go"
mkdir -p "."
cp "/tests/osscluster_lazy_reload_test.go" "osscluster_lazy_reload_test.go"
mkdir -p "."
cp "/tests/osscluster_maintnotifications_unit_test.go" "osscluster_maintnotifications_unit_test.go"

# Run tests for specific test files and packages
# For maintnotifications package, run all tests
# For root package, run only the specific test functions from our PR (not example tests)
go test -v ./maintnotifications/... && go test -v -run "^(TestLazyReloadQueueBehavior|TestClusterMaintNotifications_)" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
