#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Set dummy environment variables so integration tests won't fail in TestMain
# The actual tests will skip or fail gracefully when services aren't available
export EUREKA_ADDR="http://localhost:8761/eureka"
export ZK_ADDR="localhost:2181"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "sd/eureka"
cp "/tests/sd/eureka/integration_test.go" "sd/eureka/integration_test.go"
mkdir -p "sd/zk"
cp "/tests/sd/zk/integration_test.go" "sd/zk/integration_test.go"

# Try to build the integration tests - the fix makes them compile successfully
# Note: We use -c to compile without running, since these tests need external services
go test -c -tags integration ./sd/eureka -o /tmp/eureka_test 2>&1
eureka_status=$?

go test -c -tags integration ./sd/zk -o /tmp/zk_test 2>&1
zk_status=$?

# Success = both packages compile successfully
if [ $eureka_status -eq 0 ] && [ $zk_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
