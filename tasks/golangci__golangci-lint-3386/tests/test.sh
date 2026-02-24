#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/musttag.yml" "test/testdata/configs/musttag.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/musttag.go" "test/testdata/musttag.go"
mkdir -p "test/testdata"
cp "/tests/testdata/musttag_custom.go" "test/testdata/musttag_custom.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run only the specific musttag test subtests
# The pattern 'TestSourcesFromTestdata/musttag' matches both musttag.go and musttag_custom.go
go test -v ./test -run 'TestSourcesFromTestdata/musttag'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
