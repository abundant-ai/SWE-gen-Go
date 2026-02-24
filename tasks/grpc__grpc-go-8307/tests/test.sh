#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/ads_stream_ack_nack_test.go" "xds/internal/clients/xdsclient/test/ads_stream_ack_nack_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/ads_stream_backoff_test.go" "xds/internal/clients/xdsclient/test/ads_stream_backoff_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/ads_stream_flow_control_test.go" "xds/internal/clients/xdsclient/test/ads_stream_flow_control_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/ads_stream_restart_test.go" "xds/internal/clients/xdsclient/test/ads_stream_restart_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/ads_stream_watch_test.go" "xds/internal/clients/xdsclient/test/ads_stream_watch_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/authority_test.go" "xds/internal/clients/xdsclient/test/authority_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/lds_watchers_test.go" "xds/internal/clients/xdsclient/test/lds_watchers_test.go"

# Run the specific test package for this PR
go test -v -timeout 7m ./xds/internal/clients/xdsclient/test/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
