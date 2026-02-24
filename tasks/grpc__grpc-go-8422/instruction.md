Some xDS resource type implementations need access to information that exists on the *wrapped* resource proto (the outer `Any`/wrapper), such as fields used to derive the resource name (e.g., `ResourceName`). However, the xdsclient currently unwraps resources before invoking resource decoders and only passes the underlying raw resource bytes/proto to the decoder. This breaks decoders that expect to receive the complete resource as delivered by the server (including wrapper metadata).

Update xdsclient’s resource decoding pipeline so that decoders receive the complete marshaled bytes (and/or proto) of the resource as sent on the wire, including any wrapping `Any` layer, rather than only the unwrapped inner resource.

Concretely, when a `ResourceType` is configured with a `Decoder`, the decoder must be invoked with the original resource representation (the outer `*anypb.Any` as received). Decoders that wish to operate on the inner resource should still be able to call `xdsresource.UnwrapResource()` themselves.

Expected behavior:
- A decoder that begins by calling `xdsresource.UnwrapResource(rProto)` should continue to successfully decode resources.
- A decoder that needs wrapper-level metadata must be able to read it from the `*anypb.Any` it receives (i.e., it must not be stripped/rewritten by xdsclient before decoding).
- Any “raw bytes” retained on decoded updates (e.g., fields like `Raw` populated from the proto) must correspond to the correct resource bytes consistent with the new contract (the bytes associated with the complete resource representation passed to the decoder).

Actual behavior to fix:
- xdsclient passes only the unwrapped/inner resource to the decoder, causing implementations that require wrapper metadata (such as retrieving `ResourceName`) to fail or behave incorrectly.

APIs involved:
- `ResourceType` (including its `Decoder`)
- `xdsresource.UnwrapResource(*anypb.Any)`
- Resource decoders that accept `*anypb.Any` and unmarshal via `proto.Unmarshal(rProto.GetValue(), ...)` after optional unwrapping.