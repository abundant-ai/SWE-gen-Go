#!/bin/bash

cd /app/src

# The fix updates the Makefile to include default values for REDIS_VERSION, RE_CLUSTER, etc.
# We verify that the Makefile has these defaults.
# NOP won't have them (will fail), Oracle will have them (will pass).

# Check if Makefile has REDIS_VERSION default
if grep -q "^REDIS_VERSION ?= 8.2" Makefile; then
  echo "✓ Correct: Makefile has REDIS_VERSION default"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "✗ Incorrect: Makefile doesn't have REDIS_VERSION default"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
