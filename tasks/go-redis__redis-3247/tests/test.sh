#!/bin/bash

cd /app/src

# The fix adds REDIS_MAJOR_VERSION export to Makefile and updates docker-compose.yml
# We also need to verify the test infrastructure was updated to handle version detection

# Check 1: Verify Makefile has REDIS_MAJOR_VERSION export
if grep -q 'export REDIS_MAJOR_VERSION' Makefile; then
  echo "✓ REDIS_MAJOR_VERSION export found in Makefile"
  makefile_ok=1
else
  echo "✗ REDIS_MAJOR_VERSION export NOT found in Makefile"
  makefile_ok=0
fi

# Check 2: Verify docker-compose.yml has updated configuration
# The fix updates docker-compose to have proper Redis service configurations
if grep -q 'CLIENT_LIBS_TEST_IMAGE\|redislabs/client-libs-test' docker-compose.yml; then
  echo "✓ Updated docker-compose.yml found"
  docker_compose_ok=1
else
  echo "✗ Updated docker-compose.yml NOT found"
  docker_compose_ok=0
fi

# Check 3: Verify the test code compiles
go test -c -o /dev/null . 2>/dev/null
if [ $? -eq 0 ]; then
  echo "✓ Tests compile successfully"
  compile_ok=1
else
  echo "✗ Tests failed to compile"
  compile_ok=0
fi

# All checks must pass
if [ $makefile_ok -eq 1 ] && [ $docker_compose_ok -eq 1 ] && [ $compile_ok -eq 1 ]; then
  echo "All checks passed"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Some checks failed"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
