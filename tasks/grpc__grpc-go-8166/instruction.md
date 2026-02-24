gRPC’s OpenTelemetry stats/tracing integration is incorrectly using the OpenTelemetry global `TextMapPropagator` and global `TracerProvider` when creating and propagating spans, even when the application configures custom tracing components via gRPC’s `experimental/opentelemetry` `TraceOptions`.

This causes applications that supply their own `TextMapPropagator` and/or `TracerProvider` through `TraceOptions` to see gRPC spans still created with the global tracer provider, and context propagation/injection still performed with the global propagator, rather than the user-provided ones.

Fix the tracing integration so that when a user configures tracing using `experimental/opentelemetry.TraceOptions`, gRPC uses the `TextMapPropagator` from those options for extracting/injecting trace context and uses the `TracerProvider` from those options to create tracers/spans. The implementation should not fall back to OpenTelemetry globals when the corresponding values are provided via `TraceOptions`.

After the fix, configuring a custom propagator/tracer provider via `TraceOptions` must deterministically control:
- which propagator is used for outbound metadata injection and inbound metadata extraction, and
- which tracer provider is used for span creation (so spans are recorded by the configured provider and have the expected span context/parenting based on that propagator).