When using an xDS-enabled gRPC channel, certain failures caused by xDS client/resource problems do not include the xDS node ID in the surfaced RPC errors, even though the node ID is critical for debugging and is expected to be present whenever possible.

Currently, node ID enrichment is only reliably present for some error paths (e.g., connectivity/NACK-related errors). Other common xDS failure modes—especially “watched resource not found” and cluster resource validation failures—either produce errors without the node ID or fail RPCs indirectly (for example, by producing a nil/invalid config selector or by falling back to a policy that fails without the xDS context). This makes it hard to correlate client-side failures with xDS control-plane configuration because the node identity is missing from the final error returned to the application.

Update the xDS resolver and the CDS LB policy so that, for xDS-client-originated failures, the RPC-visible error consistently includes the xDS node ID.

Specifically:

1) xDS resolver behavior
- If a watched xDS resource is not found, the resolver must not push a nil config selector that causes RPCs to fail in an uninformative way. Instead, it should use an explicit erroring config selector so that RPC attempts fail with a clear error.
- Errors returned by the resolver’s normal config selector path must also include the xDS node ID.
- When the resolver pushes an empty service config to trigger use of the pick_first LB policy after a “resource not found” condition, it must also surface a resolver error on the channel so that pick_first fails RPCs with an error that includes the xDS node ID.

2) CDS LB policy behavior
- When the watched cluster resource is not found, the CDS LB policy must return an error picker such that RPCs fail with an error that includes the xDS node ID.
- When a received cluster resource fails validation checks, the CDS LB policy must likewise return an error picker with an error that includes the xDS node ID.

In all the above cases, the resulting application-visible RPC error should retain the relevant failure information while also being annotated with the xDS node ID (the same node identity used by the xDS client).