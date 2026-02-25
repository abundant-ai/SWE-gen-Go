#!/bin/bash

cd /app/src

# Copy HEAD version of redis_timeseries_test.go (overwrites BASE state)
mkdir -p "."
cp "/tests/redis_timeseries_test.go" "redis_timeseries_test.go"

# The key test is whether the code compiles with timeseries commands
# When bug is applied: redis_timeseries.go is deleted, so TS* methods don't exist -> compilation fails
# When fix is applied: redis_timeseries.go exists, so TS* methods exist -> compilation succeeds
go test -c -o /dev/null . 2>&1
compilation_status=$?

if [ $compilation_status -eq 0 ]; then
  echo "Compilation succeeded - timeseries commands are present"
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo "Compilation failed - timeseries commands are missing"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
