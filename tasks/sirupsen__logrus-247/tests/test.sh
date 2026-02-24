#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/entry_test.go" "entry_test.go"

# This PR adds compile-time checks that Entry and Logger implement StdLogger
# In the BASE state, entry.go has methods that return *Entry (breaking StdLogger interface)
# but logrus.go doesn't have the compile checks, so it would compile
# We need to test if Entry actually implements StdLogger by adding the check temporarily

# Create a test file that checks if Entry implements StdLogger
cat > check_interface_test.go << 'EOF'
package logrus

import "log"

// Won't compile if StdLogger can't be realized by Entry or Logger
var (
	_ StdLogger = &log.Logger{}
	_ StdLogger = &Entry{}
	_ StdLogger = &Logger{}
)
EOF

# Try to compile - this will fail in BASE state because Entry methods return *Entry
# but will succeed in HEAD state because Entry methods return void
go test -c . 2>&1
test_status=$?

# Clean up
rm -f logrus.test check_interface_test.go

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
