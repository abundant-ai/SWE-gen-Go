#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "transport/amqp"
cp "/tests/transport/amqp/publisher_test.go" "transport/amqp/publisher_test.go"
mkdir -p "transport/amqp"
cp "/tests/transport/amqp/subscriber_test.go" "transport/amqp/subscriber_test.go"

# Run the specific test files for this PR
go test -v ./transport/amqp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
