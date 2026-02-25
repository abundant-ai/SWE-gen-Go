#!/bin/bash

cd /app/src

# Remove BASE files that were renamed by bug.patch
# (fix.patch creates the correctly-named files, so we need to remove the renamed ones)
rm -f exp/zapslog/example_test.go
rm -f exp/zapslog/slog_test.go
rm -f exp/zapslog/slog.go

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "exp/zapslog"
cp "/tests/exp/zapslog/example_go121_test.go" "exp/zapslog/example_go121_test.go"
mkdir -p "exp/zapslog"
cp "/tests/exp/zapslog/example_pre_go121_test.go" "exp/zapslog/example_pre_go121_test.go"
mkdir -p "exp/zapslog"
cp "/tests/exp/zapslog/slog_go121_test.go" "exp/zapslog/slog_go121_test.go"
mkdir -p "exp/zapslog"
cp "/tests/exp/zapslog/slog_pre_go121_test.go" "exp/zapslog/slog_pre_go121_test.go"

# Run tests for the zapslog package in the exp module
cd exp && go test -v ./zapslog
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
