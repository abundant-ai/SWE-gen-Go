#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"
mkdir -p "render"
cp "/tests/render/render_test.go" "render/render_test.go"

# Run tests from context_test.go (TestContext*) and render/render_test.go (TestRender*)
go test -v -run="^(TestContext|TestRender)" ./... 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
