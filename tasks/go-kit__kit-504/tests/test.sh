#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Set dummy environment variables so integration tests won't fail in TestMain
export EUREKA_ADDR="http://localhost:8761/eureka"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "sd/eureka"
cp "/tests/sd/eureka/integration_test.go" "sd/eureka/integration_test.go"
mkdir -p "sd/eureka"
cp "/tests/sd/eureka/registrar_test.go" "sd/eureka/registrar_test.go"
mkdir -p "sd/eureka"
cp "/tests/sd/eureka/subscriber_test.go" "sd/eureka/subscriber_test.go"
mkdir -p "sd/eureka"
cp "/tests/sd/eureka/util_test.go" "sd/eureka/util_test.go"

# Run tests for the eureka package
go test -v ./sd/eureka 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
