When a server-side RPC deadline expires, the server currently relies on the application handler to return and then performs a graceful stream close. This results in the RPC not being actively cancelled by the server even though the deadline has been exceeded; instead, the stream can appear to complete normally unless the client cancels it.

The server should proactively cancel the RPC when it observes that the deadline has expired. In particular, if the handler returns after the deadline is exceeded, the server must treat the RPC as cancelled due to deadline exceeded and send an HTTP/2 RST_STREAM frame to cancel the stream (unless a RST_STREAM has already been received from the client).

Reproduction scenario:
- Start a gRPC server with a unary or streaming handler that blocks until the context deadline is exceeded and then returns.
- Make a client call with a short deadline.
- Wait for the deadline to expire.

Expected behavior:
- Once the deadline is exceeded, the server cancels the RPC and the underlying HTTP/2 stream is reset by the server using RST_STREAM.
- The RPC terminates with a deadline-exceeded cancellation semantics (i.e., it should not look like a graceful/normal completion).
- If the client has already sent a RST_STREAM for the stream, the server should not attempt to send another RST_STREAM.

Actual behavior (current bug):
- After the deadline is exceeded and the handler returns, the server does not cancel the stream; it performs a graceful close instead of resetting the stream, and may wait for the client to cancel.

Implement server-side deadline expiry handling so that deadline expiration leads to stream cancellation/reset at the transport level, producing an outgoing RST_STREAM from the server in the above scenario.