golangci-lint should support a new linter named "execinquery" that reports cases where SQL write queries are executed via database/sql query methods intended for returning rows.

Currently, enabling "execinquery" (e.g., via the enabled-linters list or equivalent CLI flag) does not produce the expected diagnostics for UPDATE statements passed to database/sql query APIs.

When analyzing code that calls methods on *sql.DB (and compatible types) like:

- Query("Update ...")
- QueryRow("Update ...")
- QueryContext(ctx, "Update ...")
- QueryRowContext(ctx, "Update ...")

golangci-lint should emit an issue for each of these calls when the SQL string represents an UPDATE query, recommending the Execute/Exec-style method instead.

The reported messages must match these texts (including method name in the message):

- For Query: "It's better to use Execute method instead of Query method to execute `UPDATE` query"
- For QueryRow: "It's better to use Execute method instead of QueryRow method to execute `UPDATE` query"
- For QueryContext: "It's better to use Execute method instead of QueryContext method to execute `UPDATE` query"
- For QueryRowContext: "It's better to use Execute method instead of QueryRowContext method to execute `UPDATE` query"

Example scenario that should be flagged:

```go
_, err := db.Query("Update * FROM hoge where id = ?", arg)
_ = err

db.QueryRow("Update * FROM hoge where id = ?", arg)

ctx := context.Background()
_, err = db.QueryContext(ctx, "Update * FROM hoge where id = ?", arg)
_ = err

db.QueryRowContext(ctx, "Update * FROM hoge where id = ?", arg)
```

Expected behavior: enabling the "execinquery" linter causes golangci-lint to report the above diagnostics at each offending call site.

Actual behavior: with "execinquery" enabled, these UPDATE-via-Query/QueryRow calls are not diagnosed (or the linter cannot be enabled/recognized), so the recommended warnings are missing.