#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "hooks/sentry"
cp "/tests/sentry_test.go" "hooks/sentry/sentry_test.go"

# Run the sentry hook tests
go test -v ./hooks/sentry/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
