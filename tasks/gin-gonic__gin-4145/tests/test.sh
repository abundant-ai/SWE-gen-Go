#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "render"
cp "/tests/render/render_test.go" "render/render_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests for render package only (context and binding fail because fix.patch doesn't restore binding/bson.go)
go test -v ./render
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
