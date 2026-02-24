#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Rebuild golangci-lint binary (needed after solution patch is applied by oracle agent)
go build -o golangci-lint ./cmd/golangci-lint

# Create a test Go file to check if deprecated linters work as noop
cat > /tmp/test_deprecated.go <<'EOF'
package main

import (
	"database/sql"
)

func test(db *sql.DB) {
	db.Query("UPDATE foo SET bar = 1") // Should trigger execinquery if active
	_ = 5 // Should trigger gomnd if active
}
EOF

# Test that execinquery doesn't produce findings (it should be noop in HEAD, active in BASE)
./golangci-lint run --no-config --disable-all --enable=execinquery /tmp/test_deprecated.go > /tmp/execinquery_output.txt 2>&1
execinquery_findings=$(grep -c "Use Exec instead" /tmp/execinquery_output.txt || true)

# In HEAD (fixed): execinquery is noop → 0 findings → test passes
# In BASE (buggy): execinquery is active → >0 findings → test fails
if [ "$execinquery_findings" -eq 0 ]; then
  test_status=0  # Linter is properly noop (expected in HEAD)
else
  test_status=1  # Linter is still active (buggy BASE state)
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
