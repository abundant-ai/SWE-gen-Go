When using an xDS-enabled gRPC server/channel, failures caused by xDS client problems do not reliably include the xDS node ID in the resulting errors. This makes it difficult to debug configuration and control-plane issues because the caller (or serving-mode callback) cannot determine which xDS node the error corresponds to.

The system should ensure that the xDS node ID is populated in errors in all relevant xDS failure scenarios, including both:

1) Errors delivered to serving-mode change callbacks via the xDS server’s serving mode change notification API (i.e., callbacks receiving `xds.ServingModeChangeArgs`), and
2) Errors returned to users as gRPC status errors from failed RPCs (`status.Status` / `status.Error`) when the RPC fails due to xDS configuration or validation problems.

Currently, in several xDS-driven failure modes, the error message (or status message) lacks the node identifier even though the xDS client and bootstrap configuration include a node ID. Update the xDS server/channel error propagation so that errors include the node ID string.

The following scenarios must produce errors that contain the xDS node ID:

- Listener resource not found for the server (LDS resource absent). This should cause the server to transition to `connectivity.ServingModeNotServing`, and the error delivered to the serving-mode change callback must include the node ID.

- Listener resource received that passes xDS client validation but fails server-side validation after receipt. This should also cause a transition to `connectivity.ServingModeNotServing`, and the callback error must include the node ID.

- Route configuration issues when there is no previously accepted/good update:
  - Route configuration resource is NACKed, or
  - Route configuration resource is not found.
  In these cases, RPCs that depend on route selection must fail with a gRPC status error whose message includes the node ID.

- Per-RPC routing/time-of-RPC errors where the matched configuration is invalid or cannot produce a forwarding decision. RPCs must fail with status errors that include the node ID for these situations:
  - Matched route configuration contains an error (NACKed or resource not found).
  - Matched route has no matching virtual host.
  - Matched route uses a non-forwarding route action.
  - No matching route found.
  - RPC denied by an RBAC policy.

In all cases above, the returned/propagated error should still use appropriate gRPC status codes (e.g., `codes.Unavailable` or other existing codes as applicable), but the error message must be augmented so it clearly contains the xDS node ID used by the server/channel (the same node ID configured via bootstrap/xDS client).