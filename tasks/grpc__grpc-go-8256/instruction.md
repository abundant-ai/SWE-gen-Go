The string representation used for xDS locality IDs in metric labels is currently inconsistent with gRFC A78. gRPC-Go uses a JSON-style encoding for locality IDs, but A78 specifies a fixed, Prometheus-label-like format.

Implement a consistent locality ID string format and parsing behavior used throughout xDS metrics/telemetry so that all places that serialize a locality into a metric label produce the exact A78 format.

Concretely:

When a `LocalityID` with fields `Region`, `Zone`, and `SubZone` is converted to a string via `LocalityID.ToString()`, it must return a string exactly of the form:

`{region="<region>", zone="<zone>", sub_zone="<subzone>"}`

Rules:
- The output must always include all three keys `region`, `zone`, and `sub_zone` in that order.
- If a field is unset/empty, it must still be present with an empty value (e.g. `zone=""`).
- Values must be quoted with double quotes and must preserve the original contents (including characters like `:`, `#`, `^`).

Additionally, implement the inverse operation `LocalityIDFromString(string) (LocalityID, error)` so that it can parse the above format back into a `LocalityID`.
- Parsing must correctly recover `Region`, `Zone`, and `SubZone` values.
- It should reject malformed strings by returning a non-nil error.

Finally, ensure that telemetry/metrics label production for locality uses this same A78 string representation. For example, the locality metric label key `grpc.lb.locality` must carry a value like:

`{region="region-1", zone="zone-1", sub_zone="subzone-1"}`

instead of any JSON encoding or other formatting.

Expected behavior: any component that reports or propagates locality as a metric/telemetry label uses the A78 format, and round-tripping via `ToString()` and `LocalityIDFromString()` produces the original `LocalityID` values.

Actual behavior: locality IDs are currently serialized in a JSON-based format which differs from A78, causing inconsistency with other gRPC implementations and incorrect metric label values.