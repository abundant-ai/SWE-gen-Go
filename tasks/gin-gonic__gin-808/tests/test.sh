#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/binding/binding_test.go" "binding/binding_test.go"
cp "/tests/render/render_test.go" "render/render_test.go"

# Run tests - testing binding and render packages
go test -v ./binding ./render 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
