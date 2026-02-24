#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export JOBS=2  # Limit parallelism for broccoli-babel-transpiler to avoid OOM

# Apply the fix patch to restore HEAD state (Oracle agent provides this)
if [ -f "/patch/fix.patch" ]; then
    patch -p1 < /patch/fix.patch
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ui/packages/consul-ui/tests/unit/mixins"
cp "/tests/ui/packages/consul-ui/tests/unit/mixins/with-blocking-actions-test.js" "ui/packages/consul-ui/tests/unit/mixins/with-blocking-actions-test.js"

# Build the UI with the updated code and test files
cd ui/packages/consul-ui
pnpm run build:ci

# Run the specific test module for this PR using ember test with --module filter
# Test module: "Unit | Mixin | with blocking actions"
pnpm exec ember test --path dist --module="Unit | Mixin | with blocking actions"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
