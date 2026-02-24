When executing a prepared statement via the extended query protocol, the client currently always sends a Describe message for the portal and waits for PostgreSQL to return a RowDescription. This happens even though the statement was already described when it was prepared, so the client already knows the result columns (name, table OID, attribute number, type OID, type modifier, etc.). The only missing piece at execution time is the per-execution result format (text vs binary) that is chosen when binding.

Add support for executing prepared statements without issuing a Describe for the portal, while preserving the same externally visible behavior as the existing execution methods.

Specifically, implement a new method on the low-level connection type named `(*PgConn).ExecPreparedStatementDescription(...)` that executes an already-prepared statement without sending a Describe portal message. Instead, it must synthesize the RowDescription that callers observe by combining:

1) the previously stored RowDescription/field metadata from the prepared statement, and
2) the result format codes requested for this specific execution (the per-column formats supplied at bind/exec time).

The synthesized RowDescription must be functionally equivalent to what PostgreSQL would have returned for that execution: consumers must still see field descriptions available before reading rows, and scanning/decoding must still work for both text and binary formats.

Expected behavior requirements:
- Calling `ExecPreparedStatementDescription` on a prepared statement must return the same rows, command tags, and errors as the existing prepared-statement execution path.
- For queries that return a result set, field descriptions must be available immediately (before iterating rows) and must contain correct column names and correct format codes for the chosen execution mode.
- For prepared statements executed with binary formats (including mixed/mostly-binary cases), decoding must work identically to the current behavior (no mismatched text/binary decoding).
- For statements that produce no result set (e.g., DDL), behavior must remain unchanged (no spurious RowDescription).
- Batch execution and regular `Conn.Query`/`Conn.QueryRow` semantics must remain unchanged; the new method is an optimization path that must not break existing APIs.

If the prepared statement’s stored metadata is missing or incompatible with the requested execution formats, the method must return a clear error rather than silently producing incorrect field descriptions or decoding failures.