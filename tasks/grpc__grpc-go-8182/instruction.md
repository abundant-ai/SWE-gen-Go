Two related runtime behavior regressions need to be fixed.

1) xDS: bootstrap config should be loaded lazily when the first xDS client is created, not during package initialization.

Currently, the default xDS client pool behaves as if it eagerly reads xDS bootstrap configuration at init time. This causes incorrect behavior when applications set xDS bootstrap environment variables after importing gRPC/xDS packages but before actually creating an xDS client.

When calling:

    xdsclient.DefaultPool.NewClient(name, metricsRecorder)

and no xDS bootstrap environment variables are set yet, the call must fail (because there is no bootstrap config to read). If the application then sets the required bootstrap environment (e.g., by pointing to a bootstrap file) and retries NewClient, the call should succeed and the pool should reflect a non-nil bootstrap config. In other words, DefaultPool must not permanently cache a “no bootstrap” result from init-time; it must attempt to read bootstrap configuration at the time the first client is actually created.

The pool’s testing hook:

    xdsclient.DefaultPool.BootstrapConfigForTesting()

should return nil before any successful NewClient call that loads bootstrap, and should return non-nil after a successful NewClient which loads bootstrap. A corresponding cleanup hook:

    xdsclient.DefaultPool.UnsetBootstrapConfigForTesting()

must allow resetting this state so subsequent runs can start with no cached bootstrap.

2) stats/opentelemetry: tracing must use the propagator and tracer provider from TraceOptions, not OpenTelemetry globals.

The OpenTelemetry integration currently pulls tracing dependencies (TextMapPropagator and TracerProvider) from the global OpenTelemetry configuration, even when the user provides explicit tracing configuration via gRPC OpenTelemetry options.

When a user configures gRPC OpenTelemetry with TraceOptions (as part of the gRPC OpenTelemetry setup), gRPC must use:

- the TextMapPropagator specified in those TraceOptions for injecting/extracting context
- the TracerProvider specified in those TraceOptions for creating spans

and must not fall back to OpenTelemetry global state when explicit options are provided.

This should ensure traces/contexts are propagated and spans are created using the user-supplied providers/propagators in end-to-end RPCs (including scenarios involving context propagation across client/server and xDS-based setups).