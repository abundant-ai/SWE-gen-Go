#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/main_test.go" "main_test.go"

# Check 1: Verify ClientInfo struct has IoThread field
if grep -q 'IoThread.*int' command.go; then
  echo "✓ IoThread field found in ClientInfo struct"
  field_ok=1
else
  echo "✗ IoThread field NOT found in ClientInfo struct"
  field_ok=0
fi

# Check 2: Verify parseClientInfo handles io-thread key
if grep -q 'case "io-thread":' command.go; then
  echo "✓ io-thread case found in parseClientInfo"
  parser_ok=1
else
  echo "✗ io-thread case NOT found in parseClientInfo"
  parser_ok=0
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
if [ $field_ok -eq 1 ] && [ $parser_ok -eq 1 ] && [ $compile_ok -eq 1 ]; then
  echo "All checks passed"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Some checks failed"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
