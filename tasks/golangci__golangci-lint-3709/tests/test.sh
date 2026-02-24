#!/bin/bash

cd /app/src

export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/tagalign_align_only.yml" "test/testdata/configs/tagalign_align_only.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/tagalign_order_only.yml" "test/testdata/configs/tagalign_order_only.yml"
mkdir -p "test/testdata/configs"
cp "/tests/testdata/configs/tagalign_sort_only.yml" "test/testdata/configs/tagalign_sort_only.yml"
mkdir -p "test/testdata"
cp "/tests/testdata/tagalign.go" "test/testdata/tagalign.go"
mkdir -p "test/testdata"
cp "/tests/testdata/tagalign_align_only.go" "test/testdata/tagalign_align_only.go"
mkdir -p "test/testdata"
cp "/tests/testdata/tagalign_order_only.go" "test/testdata/tagalign_order_only.go"
mkdir -p "test/testdata"
cp "/tests/testdata/tagalign_sort_only.go" "test/testdata/tagalign_sort_only.go"

# Rebuild golangci-lint binary with updated test files
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the tagalign tests from TestSourcesFromTestdata
# The test files include: tagalign.go, tagalign_align_only.go, tagalign_order_only.go, tagalign_sort_only.go
go test -v -run 'TestSourcesFromTestdata/(tagalign\.go|tagalign_align_only\.go|tagalign_order_only\.go|tagalign_sort_only\.go)' ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
