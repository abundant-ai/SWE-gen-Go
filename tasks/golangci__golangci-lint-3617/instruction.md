golangci-lint rule processing supports matching issues by a `path` regular expression inside rule definitions (e.g., under `issues.exclude-rules` and similarly for severity rules). Users need a way to apply a rule only outside of certain paths (or only inside a subset) without having to write a Go regexp that matches “everything except X” (Go regexp doesn’t support lookahead).

Add support for an inverted path matcher field named `path-except` on rules. This field should behave like the logical inverse of `path`:

- `path` means “this rule matches only if the issue’s file path matches the regexp”.
- `path-except` means “this rule matches only if the issue’s file path does NOT match the regexp”.

This must work anywhere rules currently support `path` matching, including:

- Exclude rules: when a rule matches, the issue should be excluded (filtered out).
- Severity rules: when a rule matches, the issue’s severity should be set/overridden by that rule.

Expected behavior examples:

1) Excluding a linter everywhere except tests

Given an exclude rule:

```yaml
issues:
  exclude-rules:
    - path-except: _test\.go
      linters:
        - forbidigo
```

This configuration should exclude `forbidigo` findings for non-test files, but should NOT exclude them for files whose path matches `_test\.go`.

Concretely:

- In a non-test file, a `forbidigo` issue like a `time.Sleep(...)` call should be filtered out by the exclude rule.
- In a `*_test.go` file, the same `forbidigo` issue should still be reported.

2) Interaction with other rule matchers

`path-except` must compose with existing match criteria (like `text`, `source`, and `linters`) the same way `path` does: the rule should only apply when all specified criteria match, with the `path-except` criterion treated as “path does not match pattern”.

For example, if a rule specifies both `text: ^nontestonly$` and `path-except: _test\.go`, then an issue with text `nontestonly` in `e.go` should match the rule, while the same issue in `e_test.go` should not.

3) Path normalization/prefix handling

When golangci-lint runs with a path prefix (e.g., due to a configured base directory), path-based matching should continue to work consistently. `path-except` should be applied to the same path string that `path` matching uses, so users can write regexps that behave predictably regardless of prefixing.

If both `path` and `path-except` are provided on the same rule, matching should be well-defined (both constraints must be satisfied: path matches `path` AND does not match `path-except`).

Implement this by extending the shared rule structure (the same one that currently contains fields like `Text`, `Source`, `Linters`, and `Path`) to include a `PathExcept` field that is configurable via YAML as `path-except`, and ensure rule evaluation logic in both exclude-rule processing and severity-rule processing honors it.