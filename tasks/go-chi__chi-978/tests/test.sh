#!/bin/bash

cd /app/src

# Verify build tags are correctly set to support tinygo
# Fixed state has: go1.22 && !tinygo (excludes tinygo from using path value methods)
# Buggy state has: go1.22 (would cause tinygo build failures)
if grep -q "//go:build go1.22 && !tinygo" path_value.go && \
   grep -q "//go:build !go1.22 || tinygo" path_value_fallback.go; then
    echo "Build tags are correct (tinygo supported)"
    test_status=0
else
    echo "Build tags are incorrect (tinygo would fail)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
