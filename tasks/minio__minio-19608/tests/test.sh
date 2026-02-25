#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/sts-handlers_test.go" "cmd/sts-handlers_test.go"

# Verify that the fixes are present in the code
# The fix changes GetValidatedUserDN and GetValidatedGroupDN to return a boolean
# indicating if the DN is under a configured base DN.

# Check 1: In internal/config/identity/ldap/ldap.go, GetValidatedUserDN should return (string, bool, error)
if grep -q "func (l \*Config) GetValidatedUserDN(conn \*ldap.Conn, userDN string) (string, bool, error)" internal/config/identity/ldap/ldap.go; then
    # Check 2: GetValidatedGroupDN should also return (string, bool, error)
    if grep -q "func (l \*Config) GetValidatedGroupDN(conn \*ldap.Conn, groupDN string) (string, bool, error)" internal/config/identity/ldap/ldap.go; then
        # Check 3: In cmd/iam.go, for groups we should NOT check underBaseDN (the key fix)
        # The fix is that we use "_, err :=" pattern for groups (discarding the boolean)
        if grep -q "validatedGroup, _, err := sys.LDAPConfig.GetValidatedGroupDN(conn, group)" cmd/iam.go; then
            # Check 4: But for parent users, we should check underBaseDN
            if grep -q "validatedParent, isUnderBaseDN, err := sys.LDAPConfig.GetValidatedUserDN(conn, parent)" cmd/iam.go && \
               grep -q 'if validatedParent == "" || !isUnderBaseDN {' cmd/iam.go; then
                test_status=0
            else
                test_status=1
            fi
        else
            test_status=1
        fi
    else
        test_status=1
    fi
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
