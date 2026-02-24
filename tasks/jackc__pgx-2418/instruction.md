When using pgx with statement caching (e.g., QueryExecModeCacheStatement / QueryExecModeCacheDescribe) and a very small server-side statement_timeout, pgx can get into a broken state if a prepared statement attempt partially succeeds on the server.

Specifically, a call path that prepares a statement can fail after the server has already created the prepared statement (i.e., after the server has accepted the Parse and sent ParseComplete), but before pgx has received the full statement description needed to finish registering it client-side. In this situation, pgx does not record the statement in its statement cache, but the server-side prepared statement with the generated name does exist on that connection. On subsequent executions, pgx attempts to prepare the same statement name again and the server returns:

ERROR: prepared statement "<generated stmtcache_...>" already exists (SQLSTATE 42P05)

This can happen intermittently in production, and can be reproduced by setting a very low statement_timeout and repeatedly running unique large queries via database/sql using the pgx driver. Expected behavior is that pgx should not get stuck repeatedly failing with SQLSTATE 42P05 after such a timeout.

Implement handling for this partial-prepare failure so that:
- If Prepare (or an implicit prepare due to statement caching) fails in a way that indicates ParseComplete occurred but the overall prepare did not complete, pgx must assume the named prepared statement may have been created on the server.
- On the next attempt to prepare the same generated statement name (or as part of recovery), pgx should deallocate that server-side prepared statement (e.g., DEALLOCATE <name> / Close message as appropriate) and then proceed so the statement cache and server state are consistent.
- Batch execution should not be able to leave newly created prepared statements in the cache if the batch fails mid-describe/prepare; the client must avoid retaining cache entries that were not fully described/ready.

Additionally, pgconn.Config needs an explicit hook that runs after the network connection is established (an AfterNetConnect-style callback) so that callers (notably tests/diagnostics) can wrap or replace the underlying net.Conn to inject delays/failures between protocol messages. This hook must be invoked for new connections and must allow returning an error to abort connection setup.

After these changes, repeatedly executing queries under an aggressive statement_timeout should not produce SQLSTATE 42P05 "prepared statement already exists" errors, and pgx should recover cleanly from timeouts occurring during the prepare/describe sequence without leaving the connection in a permanently failing state.