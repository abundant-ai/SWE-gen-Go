Several runtime behaviors in the client are incorrect and need to be fixed.

1) Digest command reply parsing
When using a Digest-style command that returns a RESP bulk string containing a hexadecimal hash (e.g. "ff", "DEADBEEF", or "ffffffffffffffff"), the command type created via `NewDigestCmd(ctx, ...)` does not reliably parse the server reply into the expected `uint64` value.

Calling `cmd.readReply(rd)` where the reader provides a bulk string containing a hex-encoded number should set the command value so that `cmd.Val()` and `cmd.Result()` return the numeric value represented by that hex string.

Requirements:
- Hex parsing must accept lowercase, uppercase, and mixed-case hex.
- It must handle values up to 16 hex digits (full `uint64` range), including `"0"` and `"ffffffffffffffff"`.
- After `SetVal(v)`, `Result()` must return the same `uint64` value with a nil error.

2) Race condition in relaxed timeout clearing
`(*Conn).ClearRelaxedTimeout()` is not safe under concurrent use. When multiple goroutines call `ClearRelaxedTimeout()` at the same time after one or more calls to `SetRelaxedTimeout(read, write)`, the internal relaxed-timeout bookkeeping can end in an inconsistent state.

Expected behavior:
- After calling `SetRelaxedTimeout(...)` N times, an internal counter used to track relaxed-timeout nesting should reflect N.
- When `ClearRelaxedTimeout()` is called concurrently from multiple goroutines, it must deterministically converge to a fully-cleared state without races or underflow/negative behavior: the counter must end at 0.
- Once cleared, the stored relaxed timeout values must be reset to 0 (read timeout, write timeout) and any relaxed deadline tracking must also be reset to 0.

3) Auth streaming manager returns nil listener
`(*Manager).Listener(poolCn, reAuth, onErr)` in the auth streaming subsystem can incorrectly return a nil listener even when no error occurs, particularly on the first call where a new listener should be created.

Expected behavior:
- If `poolCn` is non-nil, `Manager.Listener(...)` must return a non-nil listener instance and a nil error.
- The returned listener should be of type `*ConnReAuthCredentialsListener`.
- Subsequent calls to `Manager.Listener(...)` with the same connection must return the same listener instance (i.e., it should be cached/associated with that connection).
- If `poolCn` is nil, `Manager.Listener(nil, ...)` must return a non-nil error with the exact message `"poolCn cannot be nil"` and must return a nil listener.

Implement the necessary fixes so these behaviors hold consistently.