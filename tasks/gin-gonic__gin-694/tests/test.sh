#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/context_17_test.go" "context_17_test.go"
cp "/tests/context_test.go" "context_test.go"
cp "/tests/render/render_17_test.go" "render/render_17_test.go"
cp "/tests/render/render_test.go" "render/render_test.go"

# Run tests for context and render packages
go test -v . ./render 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
