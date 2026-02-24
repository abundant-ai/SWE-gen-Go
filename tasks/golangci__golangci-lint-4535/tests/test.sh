#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
# Note: Do NOT set GL_TEST_RUN=1 here because it suppresses deprecation warnings!

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Create a simple Go file to lint
mkdir -p /tmp/test-govet
cat > /tmp/test-govet/main.go << 'EOF'
package main

func main() {
	x := 1
	{
		x := 2 // shadow
		_ = x
	}
	_ = x
}
EOF

cd /tmp/test-govet
go mod init test 2>/dev/null || true

# Run golangci-lint with the govet config
# The fix should emit a deprecation warning about check-shadowing
cd /app/src
./golangci-lint run --config=test/testdata/configs/govet.yml /tmp/test-govet/main.go 2>&1 | tee /tmp/lint-output.txt

# Check if the deprecation warning is present (indicates fix is applied)
if grep -qi "check-shadowing.*deprecated" /tmp/lint-output.txt; then
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
