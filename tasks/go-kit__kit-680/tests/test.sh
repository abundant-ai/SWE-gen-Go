#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "transport/nats"
cp "/tests/transport/nats/publisher_test.go" "transport/nats/publisher_test.go"
mkdir -p "transport/nats"
cp "/tests/transport/nats/subscriber_test.go" "transport/nats/subscriber_test.go"

# Run the tests for this PR
go test -v ./transport/nats
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
