golangci-lint should support a new linter named "dupword" that reports duplicated words appearing in Go source code text (including comments and string literals).

Currently, enabling the linter with `-Edupword` is expected to produce diagnostics when the same word is repeated consecutively in natural-language text embedded in code. For example, a comment like `// ... duplicated word the the` should produce a finding indicating duplicate words `(the)` were found. Similarly, a string literal containing `... and and` should produce a finding indicating `(and)` was found.

The linter must detect duplicates at the word level. It should not treat duplicated non-word symbols as duplicate words (for example, repeated formatting verbs like `%s %s` should not be reported as duplicates just because the token repeats). The unit of detection should be words, and the output should list only the duplicated word(s), not punctuation/symbols.

When multiple duplicated words are present in the analyzed content, the diagnostic should include all duplicated words in a stable, deterministic representation (e.g., `Duplicate words (and,the) found` for content containing both `the the` and `and and`).

Implement full integration so that:
- The linter can be enabled/disabled via golangci-lint’s standard mechanisms (e.g., `-Edupword`).
- It analyzes Go packages during a normal golangci-lint run.
- It produces user-visible messages in the form `Duplicate words (<comma-separated-words>) found` for the relevant locations.

A simple reproduction scenario should work:
- A Go file containing a comment with `the the` should trigger a report for `the`.
- A Go file containing a string literal with `and and` should trigger a report for `and`.
- A single string containing multiple duplicates (including across newlines and whitespace) should report both duplicated words (e.g., `and` and `the`).