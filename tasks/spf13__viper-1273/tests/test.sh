#!/bin/bash

cd /app/src

# Set CGO_ENABLED for race detector (as used in CI)
export CGO_ENABLED=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/encoding/yaml"
cp "/tests/internal/encoding/yaml/codec_test.go" "internal/encoding/yaml/codec_test.go"
mkdir -p "internal/encoding/yaml"
cp "/tests/internal/encoding/yaml/yaml2_test.go" "internal/encoding/yaml/yaml2_test.go"
mkdir -p "internal/encoding/yaml"
cp "/tests/internal/encoding/yaml/yaml3_test.go" "internal/encoding/yaml/yaml3_test.go"
mkdir -p "."
cp "/tests/viper_test.go" "viper_test.go"
mkdir -p "."
cp "/tests/viper_yaml2_test.go" "viper_yaml2_test.go"
mkdir -p "."
cp "/tests/viper_yaml3_test.go" "viper_yaml3_test.go"

# Run tests for internal/encoding/yaml package with viper_yaml2 and viper_yaml3 build tags
# This tests the YAML codec implementations
go test -v -race -tags "viper_yaml2 viper_yaml3" ./internal/encoding/yaml
yaml_status=$?

# Run viper_test.go, viper_yaml2_test.go, viper_yaml3_test.go at root level
# These files test viper's YAML integration
go test -v -race -tags "viper_yaml2 viper_yaml3" -run "TestYAML|TestReadBufConfig|TestSafeReadConfig" .
viper_status=$?

# Test passes if both commands succeed
if [ $yaml_status -eq 0 ] && [ $viper_status -eq 0 ]; then
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
