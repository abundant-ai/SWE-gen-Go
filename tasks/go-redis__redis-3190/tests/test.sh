#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/osscluster_test.go" "osscluster_test.go"

# Check 1: Verify isContextError function exists in error.go
if grep -q 'func isContextError' error.go; then
  echo "✓ isContextError function found in error.go"
  func_ok=1
else
  echo "✗ isContextError function NOT found in error.go"
  func_ok=0
fi

# Check 2: Verify processPipelineNode uses isContextError check
if grep -q 'if !isContextError(err)' osscluster.go; then
  echo "✓ isContextError check found in osscluster.go"
  check_ok=1
else
  echo "✗ isContextError check NOT found in osscluster.go"
  check_ok=0
fi

# Check 3: Verify the test cases exist in osscluster_test.go
if grep -q "doesn't fail node with context.Canceled error" osscluster_test.go && \
   grep -q "doesn't fail node with context.DeadlineExceeded error" osscluster_test.go; then
  echo "✓ Context error test cases found in osscluster_test.go"
  test_ok=1
else
  echo "✗ Context error test cases NOT found in osscluster_test.go"
  test_ok=0
fi

# Check 4: Verify the code compiles
go build -o /dev/null . 2>/dev/null
if [ $? -eq 0 ]; then
  echo "✓ Code compiles successfully"
  compile_ok=1
else
  echo "✗ Code failed to compile"
  compile_ok=0
fi

# All checks must pass
if [ $func_ok -eq 1 ] && [ $check_ok -eq 1 ] && [ $test_ok -eq 1 ] && [ $compile_ok -eq 1 ]; then
  echo "All checks passed"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Some checks failed"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
