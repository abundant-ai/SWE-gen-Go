#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export CONSUL_NSPACES_ENABLED=0

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ui/packages/consul-ui/tests/integration/components"
cp "/tests/ui/packages/consul-ui/tests/integration/components/list-collection-test.js" "ui/packages/consul-ui/tests/integration/components/list-collection-test.js"

# CRITICAL: Run ONLY the specific test files from the PR, NOT the entire test suite!
# The test files to run are: "ui/packages/consul-ui/tests/integration/components/list-collection-test.js"
#
# TODO: Fill in the actual test command to run ONLY these specific files
#
# DO NOT run the entire test suite - it's too slow and may have unrelated failures!
#
# Examples for different languages/frameworks:
#
# Python (pytest with uv):
#   # If using uv venv at /opt/venv:
#   source /opt/venv/bin/activate
#   uv pip install -e . --no-deps 2>/dev/null || true  # Reinstall to pick up changes
#   pytest -xvs path/to/test_file.py
#   # Or without venv activation:
#   /opt/venv/bin/pytest -xvs path/to/test_file.py
#
# JavaScript/TypeScript (IMPORTANT: disable coverage thresholds when running subset!):
#   npx jest path/to/test.js path/to/test2.js --coverage=false
#   npx vitest run path/to/test.ts --coverage.enabled=false
#   npx mocha path/to/test.js path/to/test2.js
#   npx borp path/to/test.js --no-check-coverage   # Used by fastify, pino, etc.
#   npx tap path/to/test.js --no-check-coverage    # Node TAP framework
#   npx ava path/to/test.js                        # AVA framework
#
#   CRITICAL for JS/TS: DO NOT use "npm test" or "npm run test" without args!
#   These run the ENTIRE suite. Pass specific files via the test runner directly.
#   If you must use npm: npm run test -- path/to/test.js (note the -- separator)
#
# Go:
#   go test -v ./path/to/package/...
#   go test -v -run TestSpecificName ./...
#
# Rust:
#   cargo test --test test_name -- --nocapture
#   cargo test specific_test_name -- --nocapture
#
# Ruby (RSpec/Minitest):
#   bundle exec rspec path/to/spec.rb
#   bundle exec ruby -Itest path/to/test.rb
#
# Java (JUnit/Maven/Gradle):
#   mvn test -Dtest=TestClassName
#   gradle test --tests TestClassName

# Run the specific Ember test file using ember test with filter
cd ui/packages/consul-ui
node_modules/.bin/ember test --path dist --filter="Integration | Component | list collection"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
