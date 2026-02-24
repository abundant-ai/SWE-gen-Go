gRPC-Go currently lacks a supported way to override the HTTP/2 ":authority" header on a per-RPC basis. Users need to send an authority value that differs from the channel target (or default authority) for specific calls, while keeping a single ClientConn.

Implement a new call option `grpc.CallAuthority(string)` that overrides the outbound ":authority" header for only the RPC where it is applied.

Behavior requirements:
- When a user invokes an RPC with `grpc.CallAuthority("auth.example.com")`, the request must carry exactly one ":authority" value, and it must be the override value (not the channel default). The server should observe the overridden authority as the ":authority" pseudo-header.
- The override must be validated by the active security handshaker/credentials:
  - Add an optional interface that `credentials.AuthInfo` implementations may implement to validate the per-RPC authority override.
  - If `grpc.CallAuthority(...)` is set but the `AuthInfo` associated with the connection does not implement this validation interface, the RPC must fail.
  - If validation is attempted and fails (e.g., the override does not match what is permitted by the peer certificate identity), the RPC must fail.
  - For TLS-based credentials, validation must perform hostname validation against the peer certificate obtained during the handshake (i.e., accept overrides that would be valid names for the peer).
- For `insecure` credentials, any authority override must be accepted.
- For `local` credentials, any authority override must be accepted.

Failure expectations:
- When using TLS credentials, providing an authority override that does not validate against the peer certificate identity must cause the RPC to return an error (as opposed to silently using the override).
- When using TLS credentials, providing a correct/valid authority override must succeed and propagate the override to the server.

The end result should be that `grpc.CallAuthority` reliably changes the outgoing ":authority" header on a per-RPC basis while preserving transport security guarantees by requiring credential-based validation (except for insecure/local credentials, which allow any value).