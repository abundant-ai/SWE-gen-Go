#!/bin/bash

cd /app/src

# Set environment variables for tests (already set in Dockerfile but ensure they're available)
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
# Note: bug.patch renamed gocritic_settings_test.go to gocritic_test.go
# So we need to copy it to gocritic_test.go to overwrite the BASE version
mkdir -p "pkg/golinters/gocritic"
cp "/tests/pkg/golinters/gocritic/gocritic_settings_test.go" "pkg/golinters/gocritic/gocritic_test.go"

# Re-download dependencies and rebuild (in case solve.sh changed go.mod)
go mod download
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test file (not the whole package, to avoid integration tests)
# Note: The test file gocritic_settings_test.go was renamed to gocritic_test.go by bug.patch
go test -v ./pkg/golinters/gocritic/gocritic_test.go ./pkg/golinters/gocritic/gocritic.go ./pkg/golinters/gocritic/gocritic_settings.go
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
