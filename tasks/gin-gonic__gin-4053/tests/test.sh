#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/gin_test.go" "gin_test.go"
mkdir -p "internal/fs"
cp "/tests/internal/fs/fs_test.go" "internal/fs/fs_test.go"
mkdir -p "render"
cp "/tests/render/render_test.go" "render/render_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests for the specific files from this PR
go test -v . ./internal/fs/... ./render/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
