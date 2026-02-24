#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/binding_test.go" "binding/binding_test.go"
mkdir -p "."
cp "/tests/githubapi_test.go" "githubapi_test.go"
mkdir -p "."
cp "/tests/tree_test.go" "tree_test.go"

# Download any new dependencies that HEAD test files need
go mod tidy && go mod download

# Run tests for binding package and specific tests from root package
# Use -mod=mod to ignore vendor directory inconsistencies
# Run only the tests that were modified in this PR to avoid unrelated flaky tests
go test -v -mod=mod ./binding -run="TestUriBinding|TestCanSet" && \
go test -v -mod=mod . -run="TestShouldBindUri|TestGithubAPI|TestCountParams|TestTreeAddAndGet|TestTreeWildcard|TestUnescapeParameters|TestTreeWildcardConflict|TestTreeChildConflict|TestTreeDupliatePath|TestEmptyWildcardName|TestTreeCatchAllConflict|TestTreeCatchAllConflictRoot|TestTreeDoubleWildcard|TestTreeTrailingSlashRedirect|TestTreeRootTrailingSlashRedirect|TestTreeFindCaseInsensitivePath|TestTreeInvalidNodeType|TestTreeWildcardConflictEx"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
