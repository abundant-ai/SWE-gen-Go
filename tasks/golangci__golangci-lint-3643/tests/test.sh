#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/ginkgolinter/configs"
cp "/tests/testdata/ginkgolinter/configs/ginkgolinter_allow_havelen0.yml" "test/testdata/ginkgolinter/configs/ginkgolinter_allow_havelen0.yml"
mkdir -p "test/testdata/ginkgolinter/configs"
cp "/tests/testdata/ginkgolinter/configs/ginkgolinter_suppress_compare.yml" "test/testdata/ginkgolinter/configs/ginkgolinter_suppress_compare.yml"
mkdir -p "test/testdata/ginkgolinter"
cp "/tests/testdata/ginkgolinter/ginkgolinter.go" "test/testdata/ginkgolinter/ginkgolinter.go"
mkdir -p "test/testdata/ginkgolinter"
cp "/tests/testdata/ginkgolinter/ginkgolinter_havelen0.go" "test/testdata/ginkgolinter/ginkgolinter_havelen0.go"
mkdir -p "test/testdata/ginkgolinter"
cp "/tests/testdata/ginkgolinter/ginkgolinter_suppress_compare.go" "test/testdata/ginkgolinter/ginkgolinter_suppress_compare.go"
mkdir -p "test/testdata/ginkgolinter"
cp "/tests/testdata/ginkgolinter/ginkgolinter_suppress_err.go" "test/testdata/ginkgolinter/ginkgolinter_suppress_err.go"
mkdir -p "test/testdata/ginkgolinter"
cp "/tests/testdata/ginkgolinter/ginkgolinter_suppress_len.go" "test/testdata/ginkgolinter/ginkgolinter_suppress_len.go"
mkdir -p "test/testdata/ginkgolinter"
cp "/tests/testdata/ginkgolinter/ginkgolinter_suppress_nil.go" "test/testdata/ginkgolinter/ginkgolinter_suppress_nil.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the linters test for ginkgolinter specifically
# The TestSourcesFromTestdata test will pick up the ginkgolinter files and run the linter on them
go test -v -run 'TestSourcesFromTestdata/ginkgolinter' ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
