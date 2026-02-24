#!/bin/bash

cd /app/src

# Set environment variables for tests (already set in Dockerfile but ensure they're available)
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true
export GL_TEST_RUN=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pkg/golinters/godoclint/testdata"
cp "/tests/pkg/golinters/godoclint/testdata/godoclint_full_pass_test.go" "pkg/golinters/godoclint/testdata/godoclint_full_pass_test.go"

# Create godoclint.yml with require-stdlib-doclink enabled (as expected by the HEAD test file)
cat > pkg/golinters/godoclint/testdata/godoclint.yml <<'EOF'
version: "2"

linters:
  settings:
    godoclint:
      default: none
      enable:
        - pkg-doc
        - require-pkg-doc
        - start-with-name
        - require-doc
        - deprecated
        - max-len
        - no-unused-link
        - require-stdlib-doclink
      options:
        start-with-name:
          include-unexported: true
        require-doc:
          ignore-exported: false
          ignore-unexported: false
        max-len:
          length: 127
EOF

# Re-download dependencies and rebuild (in case solve.sh changed go.mod)
go mod download
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific test from the godoclint package
# The test file godoclint_full_pass_test.go is a testdata file that gets tested
# by the integration test framework in godoclint_integration_test.go
go test -v ./pkg/golinters/godoclint/... -run TestFromTestdata
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
