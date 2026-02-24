When using pgx.Conn.SendBatch(ctx, batch), errors that occur while pgx is preparing statements for queued batch items can be hard to debug because the returned error message lacks context about which SQL statement caused the failure.

Currently, if one of the queued statements fails during the prepare phase (e.g., due to a syntax error), the error returned from the first call to BatchResults.Exec() (or other result retrieval methods) is just the server error, such as:

ERROR: syntax error at or near "VALS" (SQLSTATE 42601)

This is confusing because the error is surfaced on the first result regardless of which batch item triggered the prepare failure, and the message itself does not identify the offending SQL.

Update SendBatch / batch execution so that when a statement preparation fails, the error returned includes the SQL text that was being prepared. For example, given a batch like:

batch := &pgx.Batch{}
batch.Queue("INSERT INTO batch_test (name, value) VALUES ($1, $2)", "item1", 100)
batch.Queue("INSERT INTO batch_test (name, value) VALS ($1, $2)", "item2", 200) // syntax error
batch.Queue("INSERT INTO batch_test (name, value) VALUES ($1, $2)", "item3", 300)

br := conn.SendBatch(ctx, batch)
_, err := br.Exec() // first result retrieval

The error should include both that the failure happened while preparing a statement and which statement text was being prepared, e.g.:

failed to prepare statement: INSERT INTO batch_test (name, value) VALS ($1, $2): ERROR: syntax error at or near "VALS" (SQLSTATE 42601)

This additional context should be present for prepare-time failures surfaced through batch result retrieval methods (e.g., Exec, Query, QueryRow), so users can immediately identify the culprit SQL even if the error is associated with an earlier result.