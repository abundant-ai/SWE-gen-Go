#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export JOBS=2
export CONSUL_NSPACES_ENABLED=0

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ui/packages/consul-ui/tests/integration/modifiers"
cp "/tests/ui/packages/consul-ui/tests/integration/modifiers/fix-code-block-aria-test.js" "ui/packages/consul-ui/tests/integration/modifiers/fix-code-block-aria-test.js"
mkdir -p "ui/packages/consul-ui/tests/integration/modifiers"
cp "/tests/ui/packages/consul-ui/tests/integration/modifiers/fix-super-select-aria-test.js" "ui/packages/consul-ui/tests/integration/modifiers/fix-super-select-aria-test.js"

# Build and run the specific test files modified in this PR
cd ui/packages/consul-ui

# Build for CI (uses environment=test, lighter than production)
yarn run build:ci
build_status=$?

if [ $build_status -ne 0 ]; then
  echo "Build failed with status: $build_status"
  test_status=1
else
  # Run only the specific test modules modified in this PR
  # Use ember exam to run specific test files
  npx ember exam --path dist --test-port=7357 --module="Integration | Modifier | fix-code-block-aria" --silent
  test1_status=$?

  npx ember exam --path dist --test-port=7357 --module="Integration | Modifier | fix-super-select-aria" --silent
  test2_status=$?

  # Both tests must pass
  if [ $test1_status -eq 0 ] && [ $test2_status -eq 0 ]; then
    test_status=0
  else
    test_status=1
  fi
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
