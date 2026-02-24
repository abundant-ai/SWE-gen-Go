xDS load reporting (LRS) is only configured for EDS clusters, so clients using LOGICAL_DNS clusters never start load reporting even when the xDS management server advertises an LRS server. This breaks expectations that LRS works for all supported cluster types.

When an xDS cluster is configured as LOGICAL_DNS and includes an LRS server configuration, the gRPC xDS client should:
- Plumb the load reporting server configuration through the cluster selection/balancing stack so the LRS client uses the configured server.
- Start (and keep) an LRS stream to the configured load reporting server and send load reports for RPCs routed through that cluster.

Currently, even if the management server supports LRS and the cluster config specifies an LRS server, LOGICAL_DNS clusters behave as if LRS is unset (no LRS stream is established / no reports are sent).

For non-EDS cluster types (including LOGICAL_DNS), there is no locality information available from endpoints. Load reporting should still function by reporting all load under a single locality with region/zone/sub_zone set to empty strings.

Also ensure that receiving a config update which does not change the load reporting server configuration does not tear down and recreate the existing load reporting stream (i.e., the stream should remain active and not be replaced) while continuing to report load.