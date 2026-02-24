The HTTP metrics handler currently does not properly negotiate and serve Protocol Buffer output based on the client’s request headers. As a result, clients that request Prometheus protobuf (e.g., via an Accept header for the protobuf media type) may receive the default text format instead of a protobuf-encoded response, and request header parsing for protobuf-related content types is incomplete/incorrect.

Implement protocol buffer negotiation support in the handler so that the response format is selected based on HTTP content negotiation. When a request indicates it accepts Prometheus protobuf, the handler must respond with the protobuf media type and encode the metric families as a delimited stream of `io.prometheus.client.MetricFamily` messages.

Header parsing must also correctly discriminate protobuf content types used by Prometheus. A function that selects the appropriate processor based on request headers (notably `ProcessorForRequestHeader(header http.Header)`) must support these cases:

- If the provided header is nil/illegal, return an error with the message `Received illegal and nil header.`
- If the request uses JSON with an API version header `X-Prometheus-API-Version`, then:
  - `0.0.0` must be rejected with error `Unrecognized API version 0.0.0`.
  - `0.0.1` must be accepted and return the processor `Processor001`.
- If the request uses JSON with a parameterized Content-Type like `application/json; schema="prometheus/telemetry"; version=...`, then:
  - `version=0.0.0` must be rejected with error `Unrecognized API version 0.0.0`.
  - `version=0.0.1` must return `Processor001`.
  - `version=0.0.2` must return `Processor002`.
- If the request Content-Type is protobuf, e.g. `application/vnd.google.protobuf; proto="io.prometheus.client.MetricFamily"; encoding="delimited"`, it must return `MetricFamilyProcessor`.
- If the protobuf `proto` parameter is not recognized (e.g. `proto="illegal"`), it must return an error `Unrecognized Protocol Message illegal`.
- If the protobuf `encoding` parameter is not supported (e.g. `encoding="illegal"`), it must return an error `Unsupported Encoding illegal`.

The handler must use proper HTTP content negotiation (based on the request’s `Accept` header) to choose between at least the text exposition format and the protobuf exposition format. If the client prefers protobuf and it is supported, return protobuf; otherwise return text. The `Content-Type` header of the response must match the chosen format.

Additionally, ensure that any label-signature computation remains stable and deterministic: calling `labelsToSignature(map[string]string{})` must return `14695981039346656037`, and calling it with `map[string]string{"name": "garland, briggs", "fear": "love is not enough"}` must return `15753083015552662396`.

Overall, after these changes, protobuf-capable clients should be able to retrieve metrics in protobuf format via standard HTTP negotiation, and request header discrimination for protobuf and versioned JSON inputs should behave exactly as specified above, including matching error messages.