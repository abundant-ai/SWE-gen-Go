#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/configs/configschema"
cp "/tests/internal/configs/configschema/coerce_value_test.go" "internal/configs/configschema/coerce_value_test.go"
mkdir -p "internal/configs/configschema"
cp "/tests/internal/configs/configschema/implied_type_test.go" "internal/configs/configschema/implied_type_test.go"

# Run tests for the specific package
go test -v ./internal/configs/configschema
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
