Creating metric vectors via a custom wrapper can currently lead to broken/unsafe behavior because the underlying vector implementation isn’t reliably usable outside the prometheus package. This shows up as a nil-pointer panic when code calls Describe/Collect-like behavior on a freshly constructed vector before it has been registered.

A minimal reproducer is:

```go
ch := make(chan *prometheus.Desc, 1)
v := metrics.NewCounterVec(&metrics.CounterOpts{Name: "test", Help: "help"}, []string{})
v.Describe(ch) // currently can panic with nil pointer dereference
```

The panic looks like:

```
panic: runtime error: invalid memory address or nil pointer dereference
...
github.com/prometheus/client_golang/prometheus.(*metricVec).Describe(...)
```

The library should support creating vectors of custom Metric implementations in a safe, public way. In particular:

- `prometheus.MetricVec` must be exported and usable by external packages to implement “custom metric vectors” (vectors whose per-label instance is a user-defined type implementing `prometheus.Metric`).
- `prometheus.NewMetricVec(desc *prometheus.Desc, newMetric func(lvs ...string) prometheus.Metric)` must be available and return a `*prometheus.MetricVec` that is safe to use immediately.
- Calling `Describe(chan<- *prometheus.Desc)` on a newly created `*prometheus.MetricVec` must not panic (even if the vector has not been registered yet).
- A custom vector wrapper around `*prometheus.MetricVec` should be able to expose typed helpers like `GetMetricWithLabelValues`, `GetMetricWith`, `WithLabelValues`, `With`, and `CurryWith` that return the concrete metric type (via type assertion), and those methods must behave consistently with the built-in `*prometheus.CounterVec`/`*prometheus.GaugeVec` patterns.

Overall expected behavior: external code can build a vector of custom `prometheus.Metric` implementations using `NewMetricVec`, call `Describe`/`Collect` safely prior to registration, and retrieve metrics from the vector with label values/labels without encountering initialization-related panics.