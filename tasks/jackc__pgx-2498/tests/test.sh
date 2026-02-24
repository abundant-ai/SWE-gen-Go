#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "pgconn"
cp "/tests/pgconn/config_test.go" "pgconn/config_test.go"
cp "/tests/pgconn/pgconn_test.go" "pgconn/pgconn_test.go"
mkdir -p "pgproto3"
cp "/tests/pgproto3/backend_key_data_test.go" "pgproto3/backend_key_data_test.go"
cp "/tests/pgproto3/backend_test.go" "pgproto3/backend_test.go"
cp "/tests/pgproto3/cancel_request_test.go" "pgproto3/cancel_request_test.go"
cp "/tests/pgproto3/json_test.go" "pgproto3/json_test.go"
cp "/tests/pgproto3/negotiate_protocol_version_test.go" "pgproto3/negotiate_protocol_version_test.go"

# Run only the tests from the updated test files
# Use -run to match test names from our PR test files
go test -v -run="TestParseConfigProtocolVersion|TestBackendKeyDataDecodeProtocol30|TestBackendKeyDataDecodeProtocol32|TestBackendKeyDataEncodeProtocol30|TestBackendKeyDataEncodeProtocol32|TestCancelRequestDecode|TestCancelRequestEncode|TestJSONUnmarshalBackendKeyData30|TestJSONUnmarshalBackendKeyData32|TestJSONUnmarshalCancelRequest|TestJSONUnmarshalCancelRequestLongKey|TestNegotiateProtocolVersion" ./pgconn ./pgproto3
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
