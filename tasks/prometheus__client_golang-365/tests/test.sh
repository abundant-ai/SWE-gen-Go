#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/http_test.go" "prometheus/http_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/instrument_server_test.go" "prometheus/promhttp/instrument_server_test.go"
cp "/tests/prometheus/vec_test.go" "prometheus/vec_test.go"

# Run only the specific tests from the PR test files
go test -v ./prometheus -run "^(TestInstrumentHandler)$"
test_status_1=$?

go test -v ./prometheus/promhttp -run "^(TestLabelCheck|TestMiddlewareAPI|TestInstrumentTimeToFirstWrite|TestInterfaceUpgrade)$"
test_status_2=$?

go test -v ./prometheus -run "^(TestDelete|TestDeleteWithCollisions|TestDeleteLabelValues|TestDeleteLabelValuesWithCollisions|TestMetricVec|TestMetricVecWithCollisions|TestCounterVecEndToEndWithCollision|TestCurryVec|TestCurryVecWithCollisions)$"
test_status_3=$?

# Check if all tests passed
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ] && [ $test_status_3 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
