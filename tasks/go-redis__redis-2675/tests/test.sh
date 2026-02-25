#!/bin/bash

cd /app/src

# Copy HEAD version of redis_gears_test.go (overwrites BASE state)
mkdir -p "."
cp "/tests/redis_gears_test.go" "redis_gears_test.go"

# The key test is whether the code compiles with gears commands
# When bug is applied: redis_gears.go is deleted, so gears methods don't exist -> compilation fails
# When fix is applied: redis_gears.go exists, so gears methods exist -> compilation succeeds
go test -c -o /dev/null . 2>&1
compilation_status=$?

if [ $compilation_status -eq 0 ]; then
  echo "Compilation succeeded - gears commands are present"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Compilation failed - gears commands are missing"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
