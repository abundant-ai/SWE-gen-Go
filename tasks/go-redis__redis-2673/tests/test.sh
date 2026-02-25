#!/bin/bash

cd /app/src

# Copy HEAD version of probabilistic_test.go (overwrites BASE state)
mkdir -p "."
cp "/tests/probabilistic_test.go" "probabilistic_test.go"

# The key test is whether the code compiles with probabilistic commands
# When bug is applied: probabilistic.go is deleted, so probabilistic methods don't exist -> compilation fails
# When fix is applied: probabilistic.go exists, so probabilistic methods exist -> compilation succeeds
go test -c -o /dev/null . 2>&1
compilation_status=$?

if [ $compilation_status -eq 0 ]; then
  echo "Compilation succeeded - probabilistic commands are present"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Compilation failed - probabilistic commands are missing"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
