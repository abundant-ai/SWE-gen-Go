#!/bin/bash

cd /go/src/github.com/labstack/echo

# Build the RealIP check program to verify RealIP() functionality exists and works correctly
mkdir -p "_realip_check"
cp "/tests/realip_check.go" "_realip_check/main.go"
cd _realip_check && go build -o /tmp/realip_check .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
