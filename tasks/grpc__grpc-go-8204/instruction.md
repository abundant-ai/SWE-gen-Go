Performance profiling shows excessive time spent in the ALTS record connection read path, specifically in `google.golang.org/grpc/credentials/alts/internal/conn.(*conn).Read`. This overhead is particularly visible for large or frequent reads (e.g., workloads that deliver ~16KB ALTS records repeatedly), where the current implementation spends too much time on repeated allocations, small network reads, incremental buffer growth, and extra copying.

The ALTS handshake and record read logic should be optimized to reduce CPU time and allocations while preserving existing correctness and `io.Reader` semantics.

The following problems need to be addressed:

1) Handshaker buffering inefficiency: during the ALTS handshake, a temporary buffer is allocated repeatedly inside a loop. The handshaker should reuse a single buffer across iterations instead of allocating on every loop iteration.

2) Network read size is too small: the ALTS connection currently uses a small read buffer (4KB), causing many more `Read` calls and higher overhead for large messages. The read buffer size used to pull encrypted data from the underlying transport should be increased to 32KB.

3) Inefficient buffer growth for oversized frames: when an incoming ALTS frame is larger than the current internal buffer capacity, the current strategy grows the buffer in small fixed increments (e.g., 4KB steps), resulting in repeated allocations/copies for large frames. When the implementation determines the complete frame size, it should expand the buffer directly to the required capacity so the entire frame can be read/assembled without repeated incremental growth.

4) Avoidable decrypted-message copy in `(*conn).Read`: today, `Read(p []byte)` decrypts into an internal buffer and then copies into `p` even when `p` is large enough to hold the decrypted plaintext. If the caller-provided `p` has sufficient capacity for the decrypted message, `(*conn).Read` should decrypt directly into `p` (or otherwise avoid the extra copy) while still returning the correct `n` and error behavior expected from `io.Reader`. This is important because gRPC commonly supplies ~16KB read buffers, which often matches typical ALTS record payload sizes, making the extra copy frequently avoidable.

Expected behavior:
- `NewConn` continues to produce interoperable client/server ALTS record connections.
- Data integrity is preserved: messages written with `(*conn).Write` are returned identically by the peer’s `(*conn).Read`.
- `(*conn).Read` respects `io.Reader` semantics: it returns the number of plaintext bytes placed into the provided slice and appropriate errors (including handling of EOF and partial reads).
- Performance improves for large-message and common-record-size reads by reducing allocations, reducing the number of underlying transport reads, and avoiding unnecessary copying when possible.