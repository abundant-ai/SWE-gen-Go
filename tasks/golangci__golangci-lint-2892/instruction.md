The gci linter integration is regressed: running golangci-lint with auto-fix enabled no longer rewrites files to the expected import order, and in some cases produces opaque parse/format errors instead of fixing the imports.

Reproduction examples reported by users:
- Running `golangci-lint run --fix` on a file with imports in the wrong order should rewrite the import block into the configured grouping/sorting. Instead, golangci-lint reports a gci issue and leaves the file unchanged.
- In a regression case, `golangci-lint run --fix -c <config> <file>` fails with an error like:
  `Expected '\t', Found '\n' at <file>[line 21,col 1] (gci)`
  and does not apply any fixes.

Expected behavior:
- When gci is enabled and `--fix` is provided, golangci-lint should apply gci’s formatter/write mode to rewrite the file so the import block matches gci’s configured sections and ordering.
- The rewrite should be deterministic and should properly separate import groups with blank lines according to the configuration (e.g., standard library imports first, then project/local imports, then third-party imports), producing a stable import layout.
- After the fix is applied, rerunning golangci-lint should not report “File is not `gci`-ed” for the corrected file.

Actual behavior:
- golangci-lint reports “File is not `gci`-ed” but does not auto-fix the import order even under `--fix`.
- In some cases, gci emits a low-level formatting/parsing error (e.g., the “Expected '\t', Found '\n'” message) instead of successfully rewriting the imports.

Implement/repair the gci integration so that `golangci-lint run --fix` reliably rewrites misordered imports into the correct grouped/sorted form and avoids the formatting error scenario above, restoring the previously expected developer workflow where `make lint-fix` (or equivalent) automatically fixes import ordering rather than requiring manual edits.