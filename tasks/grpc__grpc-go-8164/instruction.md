In grpc-go xDS, the default xDS client pool behavior changed between versions such that bootstrap configuration is read at package initialization time instead of when the first xDS client is created. This causes a breaking change for programs that set up the xDS bootstrap file (via the GRPC_XDS_BOOTSTRAP environment variable) after process start but before actually creating the first xDS client.

Currently, the default pool attempts to read bootstrap configuration too early. If no supported bootstrap environment variables are set at init time, the pool is constructed without a bootstrap config. Later, even if GRPC_XDS_BOOTSTRAP is set to point at a valid bootstrap file, creating an xDS client from the default pool still fails because the pool never re-reads the environment.

The default pool should lazily load bootstrap configuration from the environment when an xDS client is created for the first time (or when needed), rather than permanently locking in an “unset/invalid” configuration from init time.

Reproduction scenario:
1) Start a process with no GRPC_XDS_BOOTSTRAP (and no other supported xDS bootstrap env vars) set.
2) Attempt to create an xDS client using xdsclient.DefaultPool.NewClient(name, metricsRecorder). This should fail because there is no bootstrap config.
3) Set GRPC_XDS_BOOTSTRAP to point to a valid bootstrap JSON file.
4) Call xdsclient.DefaultPool.NewClient(name, metricsRecorder) again.

Expected behavior: step (4) succeeds, and the default pool now has a non-nil bootstrap configuration loaded from the environment.

Actual behavior: step (4) continues to fail because DefaultPool never reloads bootstrap configuration after the initial init-time attempt.

Implement the restoration of the pre-regression behavior: the default pool must read bootstrap configuration before creating the first xDS client (lazy load), not at package init time. Also ensure that any introspection helper like DefaultPool.BootstrapConfigForTesting() reflects nil before the first successful client creation/config load, and becomes non-nil after a client is successfully created using an env-provided bootstrap file.