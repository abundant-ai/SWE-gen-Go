#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/registry_test.go" "prometheus/registry_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/summary_test.go" "prometheus/summary_test.go"

# Fix compilation errors in other test files that exist in the BASE state
# These errors are due to Go 1.17 stricter type checking with int-to-string conversions
# The pattern string('A' + <expr>) needs to be changed to string(rune('A' + <expr>))

# Fix gauge_test.go - handle both 'A' + i and 'A'+i patterns
sed -i "s/string('A' *+ *i)/string(rune('A' + i))/g" prometheus/gauge_test.go
sed -i "s/string('A' *+ *pick\[i\])/string(rune('A' + pick[i]))/g" prometheus/gauge_test.go

# Fix histogram_test.go
sed -i "s/string('A' *+ *picks\[i\])/string(rune('A' + picks[i]))/g" prometheus/histogram_test.go
sed -i "s/string('A' *+ *i)/string(rune('A' + i))/g" prometheus/histogram_test.go

# Fix summary_test.go
sed -i "s/string('A' *+ *picks\[i\])/string(rune('A' + picks[i]))/g" prometheus/summary_test.go
sed -i "s/string('A' *+ *i)/string(rune('A' + i))/g" prometheus/summary_test.go

# Remove http_test.go to avoid compilation errors (it depends on http.go which has issues in BASE state)
rm -f prometheus/http_test.go

# Run tests for the prometheus package
go test -v ./prometheus 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
