#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command"
cp "/tests/internal/command/providers_lock_test.go" "internal/command/providers_lock_test.go"
mkdir -p "internal/command/testdata/providers-lock/with-tests/fs-mirror/registry.terraform.io/hashicorp/test/1.0.0/os_arch"
cp "/tests/internal/command/testdata/providers-lock/with-tests/fs-mirror/registry.terraform.io/hashicorp/test/1.0.0/os_arch/terraform-provider-test" "internal/command/testdata/providers-lock/with-tests/fs-mirror/registry.terraform.io/hashicorp/test/1.0.0/os_arch/terraform-provider-test"

# Run tests for the specific package containing the test file
go test -v ./internal/command
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
