#!/bin/bash

cd /app/src

# Set CGO_ENABLED for race detector (as used in CI)
export CGO_ENABLED=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/encoding/yaml"
cp "/tests/internal/encoding/yaml/yaml2_test.go" "internal/encoding/yaml/yaml2_test.go"
mkdir -p "internal/encoding/yaml"
cp "/tests/internal/encoding/yaml/yaml3_test.go" "internal/encoding/yaml/yaml3_test.go"
mkdir -p "."
cp "/tests/viper_yaml2_test.go" "viper_yaml2_test.go"
mkdir -p "."
cp "/tests/viper_yaml3_test.go" "viper_yaml3_test.go"

# Run only the specific test packages with race detector
# Package 1: internal/encoding/yaml (yaml2_test.go, yaml3_test.go)
go test -v -race ./internal/encoding/yaml
test_status_1=$?

# Package 2: root package (viper_yaml2_test.go, viper_yaml3_test.go)
go test -v -race -run "Yaml[23]" .
test_status_2=$?

# Overall status: fail if either failed
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
