The xDS client currently marks a resource update as NACKed in its metadata when it fails to decode an xDS resource from the management server, but the error surfaced to callers is not specifically classifiable as a NACK error. As a result, code handling watch errors in the xdsresource package cannot distinguish “invalid configuration received from the management server (NACK)” from other error categories.

Introduce a dedicated error type for NACKed updates and ensure it is used consistently.

Implement a new xdsresource error type (named `ErrTypeNack`) that represents errors caused by invalid configuration received from the xDS management server (i.e., updates that the client NACKs).

When an xDS response is received and resource decoding fails such that the update is treated as a NACK, the error delivered to watchers (e.g., via `OnError(err error, onDone xdsresource.OnDoneFunc)`) must be created using `xdsresource.NewErrorf(...)` and must be classified as `ErrTypeNack`. This classification must be preserved when propagated through the xdsclient watch/update pipeline.

Expected behavior:
- If a resource update is NACKed due to decode/validation errors, the associated error must be identifiable as type `ErrTypeNack` (via the xdsresource error-typing mechanism).
- Non-NACK errors (transport errors, other internal errors) must not be mislabeled as `ErrTypeNack`.
- Existing ACK/NACK behavior on the ADS stream must remain correct: after an ACKed version, a NACK for a subsequent bad response should be sent using the previously ACKed version and the current nonce, while watcher callbacks receive an `ErrTypeNack`-classified error for the bad update.

Actual behavior:
- NACKed updates set NACK metadata, but watcher-visible errors are not classified as NACK-specific, making it impossible to reliably detect NACK conditions within xdsresource-based consumers.