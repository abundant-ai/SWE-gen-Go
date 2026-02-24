When using gRPC-Go with the OpenTelemetry stats/tracing integration enabled, there is currently no trace-level signal indicating that an RPC was blocked waiting for the name resolver to produce its first address update. This makes it difficult to diagnose startup latency and “stuck before first pick” behavior where calls hang until name resolution completes (or until the ClientConn is closed).

Add an OpenTelemetry trace event that records name resolution delay for RPCs that are forced to wait for the resolver’s initial update. The event must be emitted on the relevant span created by the gRPC OpenTelemetry instrumentation (i.e., the per-RPC/client span), and it should fire once name resolution completes and the RPC can proceed (or otherwise becomes unblocked).

The event should:
- Be present when an RPC begins while the ClientConn has not yet received the resolver’s first update, and the RPC therefore waits for name resolution before it can proceed.
- Not be emitted for RPCs that start after name resolution is already available (no waiting occurred).
- Record the delay duration between the time the RPC started waiting for name resolution and the time the first resolver update is received (a non-negative duration).
- Work correctly with manual/custom resolvers that provide the first update asynchronously.

After implementing this, traces produced by the gRPC OpenTelemetry integration should include this event in the above scenario, allowing users to see that name resolution contributed X time of delay before the RPC progressed.