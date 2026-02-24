#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "hooks/test"
cp "/tests/hooks/test/test.go" "hooks/test/test.go"
cp "/tests/hooks/test/test_test.go" "hooks/test/test_test.go"

# Run the test hook tests
go test -v ./hooks/test/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
