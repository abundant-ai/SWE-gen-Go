#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/golinters/nolintlint"
cp "/tests/pkg/golinters/nolintlint/nolintlint_test.go" "pkg/golinters/nolintlint/nolintlint_test.go"
mkdir -p "pkg/lint/lintersdb"
cp "/tests/pkg/lint/lintersdb/enabled_set_test.go" "pkg/lint/lintersdb/enabled_set_test.go"
mkdir -p "pkg/printers"
cp "/tests/pkg/printers/tab_test.go" "pkg/printers/tab_test.go"
mkdir -p "pkg/printers"
cp "/tests/pkg/printers/text_test.go" "pkg/printers/text_test.go"
mkdir -p "test"
cp "/tests/enabled_linters_test.go" "test/enabled_linters_test.go"
mkdir -p "test/testshared"
cp "/tests/testshared/analysis_test.go" "test/testshared/analysis_test.go"
mkdir -p "test/testshared"
cp "/tests/testshared/runner_test.go" "test/testshared/runner_test.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests from this PR
go test -v ./pkg/golinters/nolintlint ./pkg/lint/lintersdb ./pkg/printers ./test/testshared
test_status_1=$?

# Run only the specific test function from ./test package (not all tests)
go test -v -run TestEnabledLinters ./test
test_status_2=$?

# Both must pass
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
