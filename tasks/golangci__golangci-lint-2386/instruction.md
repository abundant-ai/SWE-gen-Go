golangci-lint currently supports emitting results in a single output format via the `--out-format` flag, typically writing to stdout. Users need to generate multiple outputs from a single run (e.g., a human-readable report to stdout and a machine-readable report like checkstyle/sarif to a file) without running the linter twice.

Extend `--out-format` to accept a comma-separated list of outputs, where each output entry may optionally specify a destination using `FORMAT:DEST`. `DEST` must support a filesystem path, `stdout`, or `stderr`.

Examples of valid invocations:

- `golangci-lint run --out-format line-number,checkstyle:report.xml ./...`
- `golangci-lint run --out-format line-number:stdout,checkstyle:stderr ./...`
- `golangci-lint run --out-format json:out.json,line-number:stdout <package-or-files>`

Expected behavior:

- For each specified output entry, golangci-lint must emit the same set of discovered issues in the requested format.
- Each output must be written to its own target (file path, stdout, or stderr) as specified.
- When a file path is provided, the file should be created/overwritten with the formatted output for that entry.
- When multiple outputs are specified, stdout should contain only the formats explicitly routed to stdout (and stderr only those routed to stderr). Output for file destinations must not appear on stdout/stderr.
- Exit codes must remain consistent with current behavior (e.g., when issues are found, the process should still exit with the “issues found” exit code) regardless of how many outputs are produced.

Input validation requirements:

- `--out-format` entries must reject unknown format names with a clear error.
- If an entry contains `:` it must have a non-empty destination; malformed values (e.g., trailing `:`, empty format, or empty destination) should produce an error rather than silently falling back.
- Reserved destinations `stdout` and `stderr` must be recognized case-sensitively as those literal strings.

After implementing this, a single run that finds issues should be able to simultaneously:

- print a `line-number` style message like `testdata/gci/gci.go:7: File is not `gci`-ed` to stdout, and
- write a second representation of the same issue set (e.g., checkstyle XML) to a specified file path (or to stderr if requested),

without changing existing single-output behavior when `--out-format` contains only one entry.