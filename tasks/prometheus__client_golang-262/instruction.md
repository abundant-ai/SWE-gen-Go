Creating a Summary metric currently fails or behaves incorrectly when the user intentionally wants no quantiles.

When constructing a Summary via NewSummary(...) or NewSummaryVec(...), passing an explicitly empty objectives map (i.e., a constructed-but-empty map) should be supported to mean “no quantiles should be calculated/exported”. Today, the Summary implementation treats “no objectives provided” and “explicitly empty objectives” the same way and forces default objectives (via DefObjectives), which makes it impossible to create a Summary without quantiles.

The library should distinguish between:
- Objectives being unset (nil): this should continue to use the current default behavior for now (using DefObjectives), but DefObjectives is deprecated and will be removed in a future version.
- Objectives being explicitly set to an empty map: this must result in a Summary that exports only the _sum and _count series and does not export any quantile series.

Example expected behavior:

```go
s := prometheus.NewSummary(prometheus.SummaryOpts{
  Name: "request_duration_seconds",
  Help: "...",
  Objectives: map[float64]float64{}, // explicitly empty
})

s.Observe(1.23)
```

Expected: the gathered metric family for this Summary includes only sample count and sample sum; it must not include any quantile samples.

Actual (current): the Summary ends up using default quantile objectives, producing quantile samples despite the user providing an explicitly empty objectives map.

In addition, DefObjectives should be marked deprecated in the public API (as it is planned to be removed in v0.10). Any internal/defaulting logic should be compatible with that deprecation: users should be encouraged to set Objectives explicitly when they want quantiles.

This change should not break existing users who rely on the default Summary behavior when Objectives is not provided at all (nil), but it must enable the explicit “no quantiles” use case by honoring an empty Objectives map.