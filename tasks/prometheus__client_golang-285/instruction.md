The HTTP handler instrumentation in promhttp is currently provided via an “all or nothing” helper (InstrumentHandler), which makes it difficult for users to compose only the pieces they want (in-flight gauge, request counter, duration, request/response size, etc.) and to control which registry collectors are registered with.

Implement a composable middleware-style instrumentation API for net/http handlers.

Users must be able to wrap an existing http.Handler by composing multiple middleware functions, e.g. nesting wrappers so they can independently enable:
- in-flight request tracking
- request counting partitioned by status code and method
- request duration tracking partitioned by method (and supporting custom buckets/const labels)
- response size and/or request size tracking

The new middleware functions must include (at minimum) the following public functions, each taking the relevant metric and a next http.Handler and returning an http.Handler:
- InstrumentHandlerInFlight(g prometheus.Gauge, next http.Handler) http.Handler
- InstrumentHandlerCounter(c *prometheus.CounterVec, next http.Handler) http.Handler
- InstrumentHandlerDuration(obs prometheus.ObserverVec, next http.Handler) http.Handler
- InstrumentHandlerResponseSize(obs prometheus.ObserverVec, next http.Handler) http.Handler

They must be composable so code like the following is valid and works:

chain := InstrumentHandlerInFlight(inFlightGauge,
    InstrumentHandlerCounter(counter,
        InstrumentHandlerDuration(histVec,
            InstrumentHandlerResponseSize(responseSize, handler),
        ),
    ),
)

The middleware must NOT implicitly register any collectors; it should only observe/update the collectors passed in. (This is required so callers can use custom registries instead of the default registry.)

To support using different metric types for observing (histograms, summaries, or custom observers), ensure the core prometheus package exposes an Observer interface (single Observe(float64)) and an ObserverVec interface for “vector of observers” label selection. ObserverFunc must be supported so users can adapt other metric operations (e.g., Gauge.Set) to the Observer interface.

ObserverVec must be usable with HistogramVec and SummaryVec label accessors, so that code like the following compiles and works without needing type assertions:

his := prometheus.NewHistogramVec(...)
his.WithLabelValues("foo").Observe(v)

In other words, the label accessor methods on HistogramVec and SummaryVec (e.g., WithLabelValues / With) must return something that supports Observe(float64) (via the Observer interface), rather than requiring consumers to depend on the concrete Histogram/Summary types.

The instrumentation must correctly derive labels for code and method where applicable:
- method label should reflect r.Method
- code label should reflect the final HTTP status code written by the handler

If a wrapped handler never explicitly writes a status code, the instrumentation currently ends up reporting code as 0; this behavior should be defined and handled consistently by the middleware (do not crash or mislabel). The middleware must still record metrics in this case.

The implementation must build with a Go version that supports http.Pusher (Go 1.8+), because handlers may need to interact with HTTP/2 server push. Any public API relying on http.Pusher must compile and work when available.

Overall expected behavior: users can compose the new middleware helpers to instrument a handler; metrics are updated appropriately after serving a request; the API supports histograms/summaries through Observer/ObserverVec without forcing users to use concrete metric types; and no implicit registration to the default registry occurs.