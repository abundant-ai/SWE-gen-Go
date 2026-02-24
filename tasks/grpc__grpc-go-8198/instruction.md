Some implementations of `credentials.PerRPCCredentials` need access to request-scoped information (method name and transport/auth properties) via `credentials.RequestInfoFromContext(ctx)`. Today, the only supported way to populate that data in a `context.Context` is via an internal-only helper (`internal/credentials.NewRequestInfoContext`), which makes it impossible for users outside of `google.golang.org/grpc` to construct a context that `RequestInfoFromContext` can read.

This blocks two real use cases:

1) Unit testing `PerRPCCredentials` implementations in external projects. These implementations often check things like `RequestInfoFromContext(ctx).AuthInfo` and/or the `SecurityLevel` on `credentials.CommonAuthInfo` to decide whether to return metadata.

2) Reusing existing `PerRPCCredentials` implementations in alternative client/transport stacks (e.g., code that uses gRPC-generated stubs and APIs but does not use the standard gRPC transport/handshake), where there is no internal package access.

Implement a public (experimental) API in package `credentials` named `NewContextWithRequestInfo(ctx context.Context, ri credentials.RequestInfo) context.Context` (name per release note/PR intent) which returns a derived context that allows `credentials.RequestInfoFromContext` to retrieve the exact `RequestInfo` value that was provided.

Expected behavior:
- Calling `credentials.RequestInfoFromContext(credentials.NewContextWithRequestInfo(ctx, ri))` should return a `RequestInfo` equal to `ri`.
- The `RequestInfo` must preserve the `Method` and `AuthInfo` fields. In particular, callers must be able to attach an `AuthInfo` implementation embedding `credentials.CommonAuthInfo{SecurityLevel: ...}` and later observe that security level when their `PerRPCCredentials.GetRequestMetadata(ctx, ...)` runs.
- `PerRPCCredentials` implementations that require transport security should be able to make their transport-security decisions based on the `AuthInfo`/`SecurityLevel` accessible through `RequestInfoFromContext` when the context was created using this new public helper.

Actual behavior before the change:
- External callers cannot create a context that `credentials.RequestInfoFromContext` understands, because the only constructor is internal; as a result, `RequestInfoFromContext(ctx)` returns an empty/absent `RequestInfo` and `PerRPCCredentials` implementations that depend on it cannot be tested or reused outside this module.

Add/update any necessary exports/wiring so the new public function works consistently anywhere `RequestInfoFromContext` is used, without requiring imports of internal packages.