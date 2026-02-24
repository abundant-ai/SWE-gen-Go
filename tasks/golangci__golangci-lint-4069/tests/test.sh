#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=1
export GOLANGCI_LINT_INSTALLED=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test"
cp "/tests/linters_test.go" "test/linters_test.go"
mkdir -p "test/testdata/protogetter"
cp "/tests/testdata/protogetter/go.mod" "test/testdata/protogetter/go.mod"
mkdir -p "test/testdata/protogetter"
cp "/tests/testdata/protogetter/go.sum" "test/testdata/protogetter/go.sum"
mkdir -p "test/testdata/protogetter/proto"
cp "/tests/testdata/protogetter/proto/test.go" "test/testdata/protogetter/proto/test.go"
mkdir -p "test/testdata/protogetter/proto"
cp "/tests/testdata/protogetter/proto/test.pb.go" "test/testdata/protogetter/proto/test.pb.go"
mkdir -p "test/testdata/protogetter/proto"
cp "/tests/testdata/protogetter/proto/test.proto" "test/testdata/protogetter/proto/test.proto"
mkdir -p "test/testdata/protogetter/proto"
cp "/tests/testdata/protogetter/proto/test_grpc.pb.go" "test/testdata/protogetter/proto/test_grpc.pb.go"
mkdir -p "test/testdata/protogetter"
cp "/tests/testdata/protogetter/protogetter.go" "test/testdata/protogetter/protogetter.go"

# Rebuild golangci-lint binary (needed if fix.patch modified source code)
go mod download
cd scripts/gen_github_action_config && go mod download && cd ../..
go build -o golangci-lint ./cmd/golangci-lint

# Run the specific tests for this PR
# The test framework runs golangci-lint against files in test/testdata/protogetter
# We run the TestSourcesFromTestdataSubDir test filtered to just protogetter
go test -v -run "TestSourcesFromTestdataSubDir/protogetter" ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
