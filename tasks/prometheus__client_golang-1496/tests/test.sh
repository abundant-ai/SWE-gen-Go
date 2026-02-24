#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/github.com/golang/gddo/httputil/header"
cp "/tests/internal/github.com/golang/gddo/httputil/header/header_test.go" "internal/github.com/golang/gddo/httputil/header/header_test.go"
mkdir -p "internal/github.com/golang/gddo/httputil"
cp "/tests/internal/github.com/golang/gddo/httputil/negotiate_test.go" "internal/github.com/golang/gddo/httputil/negotiate_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/http_test.go" "prometheus/promhttp/http_test.go"

# Run tests for the specific packages touched by this PR
go test -v ./internal/github.com/golang/gddo/httputil/header ./internal/github.com/golang/gddo/httputil ./prometheus/promhttp 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
