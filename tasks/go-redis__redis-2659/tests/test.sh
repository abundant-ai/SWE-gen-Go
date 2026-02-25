#!/bin/bash

cd /app/src

# Copy HEAD version of commands_test.go (overwrites BASE state)
mkdir -p "."
cp "/tests/commands_test.go" "commands_test.go"

# The key test is whether the code compiles with InfoMap command
# When bug is applied: InfoMap and InfoCmd are deleted -> compilation fails
# When fix is applied: InfoMap and InfoCmd exist -> compilation succeeds
go test -c -o /dev/null . 2>&1
compilation_status=$?

if [ $compilation_status -eq 0 ]; then
  echo "Compilation succeeded - InfoMap command is present"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Compilation failed - InfoMap command is missing"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
