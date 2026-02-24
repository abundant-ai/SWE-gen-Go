#!/bin/bash

cd /app/src

export GOPATH=/go
export PATH="/usr/local/go/bin:${GOPATH}/bin:/usr/bin:/bin:${PATH}"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/zsh_completions_test.go" "zsh_completions_test.go"

# Create minimal test helper with emptyRun since we can't use command_test.go (has compilation errors)
cat > test_helpers_test.go <<'EOF'
package cobra

func emptyRun(*Command, []string) {}
EOF

# Temporarily rename other test files to avoid compilation errors in buggy state
for f in args_test.go bash_completions_test.go cobra_test.go command_test.go; do
  [ -f "$f" ] && mv "$f" "${f}.bak"
done

# Run tests from the specific test file modified in this PR
go test -v .
test_status=$?

# Cleanup
rm -f test_helpers_test.go
for f in args_test.go.bak bash_completions_test.go.bak cobra_test.go.bak command_test.go.bak; do
  [ -f "$f" ] && mv "$f" "${f%.bak}"
done

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
