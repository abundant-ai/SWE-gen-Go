The Prometheus client’s telemetry decoding logic needs to be extracted into a reusable decoding package while preserving correct API-version discrimination and decoding behavior for supported protocol versions.

Currently, callers need a stable way to select the right decoder from HTTP request headers and then decode a complete metrics message body into samples, without the decoder closing the underlying stream. Additionally, protocol 0.0.2 support must be represented in a way that allows equality comparisons (i.e., it must not be a function literal), so that callers can reliably compare the returned processor against known processors.

Implement and/or fix the following behaviors:

1) Header-based processor selection

Provide a function:

    ProcessorForRequestHeader(header http.Header) (Processor, error)

It must behave as follows:
- If the provided header is nil (or otherwise illegal/absent), return (nil, error) with the message:

    "Received illegal and nil header."

- It must recognize Prometheus telemetry API versions from either of these header styles:
  - Legacy header: "X-Prometheus-API-Version" with values like "0.0.1".
  - Media-type parameter: a "Content-Type" header like:

        application/json; schema="prometheus/telemetry"; version=0.0.1

- For version "0.0.1", it must return Processor001 with nil error.
- For version "0.0.2", it must return Processor002 with nil error.
- For any other version (e.g. "0.0.0"), return (nil, error) with the message:

    "Unrecognized API version 0.0.0"

2) Stable processor identifiers

The exported processors (at least Processor001 and Processor002) must be comparable by equality (e.g., can be checked with `==` against the known processor variables). In particular, Processor002 must not be a function literal; it should be represented in a comparable form so callers can do exact matching.

3) Single-body processing API and stream ownership

The decoder must provide a processing entrypoint named:

    ProcessSingle(...)

This function is intended to process complete message bodies (not incremental streaming chunks). Ensure that:
- The old name `Process()` is replaced/renamed to `ProcessSingle()` in the public API.
- Processing does not close the provided stream/reader; the caller remains responsible for closing it.

4) Processing options that affect metric body behavior

Decoding should accept options that allow callers to control behavioral changes when processing metric bodies (e.g., how base labels are applied/merged, and other protocol-specific handling). These options must be plumbed through the processing pipeline so that decoding behavior can be altered consistently across supported protocol versions.

5) Fingerprint ordering correctness

Provide a `Fingerprint` type with a method:

    Less(other *Fingerprint) bool

It must define a strict ordering consistent with comparing (in order) the fields used for ordering: hash, firstCharacterOfFirstLabelName, labelMatterLength, and lastCharacterOfLastLabelValue, so that a list of fingerprints sorted by this comparator is strictly increasing.

When these behaviors are implemented, callers should be able to:
- Select a processor from an HTTP header via `ProcessorForRequestHeader`.
- Compare the selected processor against known exported processors (including 0.0.2).
- Decode a full telemetry JSON body via `ProcessSingle` without having their stream closed unexpectedly.
- Adjust decoding behavior via processing options while maintaining correct decoding output for supported protocol versions.