The OpenTelemetry gRPC integration currently couples tracing and metrics interception such that users cannot enable/disable tracing and metrics independently. When configuring OpenTelemetry instrumentation, it should be possible to install only tracing interceptors, only metrics interceptors, or both, without accidentally registering the other signal’s behavior.

Right now, constructing instrumentation intended for metrics-only can still result in tracing-related interceptors being applied (and vice versa), leading to unexpected spans being created or unexpected metric instruments being initialized/registered.

Update the OpenTelemetry stats/interceptor configuration so that tracing and metrics are separated into distinct interceptors (and/or constructor options) with clear, independent enablement. After the change:

- Creating a client/server metrics handler (e.g., via the metrics-specific stats handler/recorder types) must initialize and emit only metrics; it must not install or invoke tracing interceptors or create spans.
- Creating a client/server tracing interceptor must create spans as expected but must not initialize metric instruments or emit metrics unless metrics instrumentation is explicitly enabled.
- Metrics registry behavior must remain correct: default metrics are always available, while non-default metrics only emit when explicitly included in the MetricsOptions/selection used to initialize the metrics handler.
- Optional labels must be handled correctly: when optional labels are not provided, emitted metrics should omit them; when provided, emitted metrics should include them with the expected attribute keys/values.

In particular, ensure that the metrics recorder/handler types used for OpenTelemetry metrics (client and server) can be initialized and used to record measurements on registered metric handles (including int64 counters and other supported instruments) and that the resulting OpenTelemetry metric export contains the expected timeseries and attributes for default and explicitly-enabled non-default metrics, without any tracing side effects.