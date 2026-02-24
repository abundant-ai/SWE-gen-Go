JSON serialization for Prometheus metrics and registries is currently overly complex and inconsistent, relying on a custom `AsMarshallable()` method on the `Metric` interface and ad-hoc `map[string]interface{}` construction. This causes maintainability issues and makes it harder to ensure consistent JSON output across metric types and the registry HTTP handler.

Update the marshaling behavior so that metrics and registries use Go’s standard `encoding/json` mechanisms:

- Remove `AsMarshallable()` from the `Metric` interface and ensure metric types implement `json.Marshaler` via `MarshalJSON()`.
- Ensure JSON output for metrics matches the expected stable structure and formatting.

For example, when a `Gauge` is marshaled with `json.Marshal(gauge)`, it must produce JSON with the shape:

- With no samples set: `{"type":"gauge","value":[]}`
- After `Set(nil, 1)`: `{"type":"gauge","value":[{"labels":{},"value":1}]}`
- When labels are an empty map, labels must still serialize as `{}` (not `null`).
- If the same label set is set multiple times, the most recent value must be reflected.
- After `ResetAll()`, the value must become an empty array again.
- With non-empty labels like `map[string]string{"handler":"/foo"}`, labels must serialize as `{"handler":"/foo"}`.

Similarly, `Counter` must marshal as:

- With no samples: `{"type":"counter","value":[]}`
- After `Set(nil, 1)`: `{"type":"counter","value":[{"labels":{},"value":1}]}`
- `Increment(labels)` must create or update the sample for that label set by adding 1.
- `Decrement(labels)` must subtract 1.
- Labels must always encode as an object (empty `{}` when no labels) and the resulting JSON must be deterministic and match the exact expected strings.

Additionally, the `Registry` itself should support JSON encoding directly by implementing `MarshalJSON()` so callers can do `json.Marshal(registry)`. Remove any registry-specific dumping helpers (e.g., writer-based dumping functions) and ensure the registry HTTP handler can emit the same JSON representation using standard JSON marshaling.

The end result should be that `json.Marshal()` on metric instances and on a registry produces the correct, stable JSON output with the required fields (including `type` and `value` for metrics), correct handling of nil vs empty labels, and correct update/reset semantics reflected in the marshaled data.