The gofmt linter integration currently only supports standard gofmt behavior (including the existing simplify option), but it does not support gofmt-style rewrite rules (the equivalent of gofmt’s `-r` functionality). As a result, users cannot configure golangci-lint to apply AST rewrite transformations like `interface{} -> any` or slice simplifications such as `a[b:len(a)] -> a[b:]` as part of gofmt checking/fixing.

Add support for a new gofmt linter setting named `rewrite-rules`, which is a list of rewrite rule objects. Each rule has two string fields: `pattern` and `replacement`. When this option is configured, the gofmt linter must apply all configured rewrite rules when formatting/checking files.

Expected behavior:
- With `linters-settings.gofmt.rewrite-rules` configured, the gofmt linter should treat code as not properly formatted if applying the configured rewrite rules would change the file contents (even if plain gofmt would not change it).
- When running with autofix enabled, the rewritten output should be produced (e.g., code containing `vals[1:len(vals)]` should be rewritten to `vals[1:]`, and `interface{}` should be rewritten to `any`), and the run should succeed with exit code 0.
- Multiple rewrite rules must be supported and applied in the order they are provided.

Actual behavior to fix:
- Configuring `rewrite-rules` currently has no effect (or is not recognized), so code that should be rewritten is not flagged by the gofmt linter and is not rewritten during autofix.

Configuration example that must work:
```yaml
linters-settings:
  gofmt:
    rewrite-rules:
      - pattern: 'interface{}'
        replacement: 'any'
      - pattern: 'a[b:len(a)]'
        replacement: 'a[b:]'
```

After implementing this, running the gofmt linter against code containing constructs matching these patterns must report a gofmt formatting issue when not fixed, and must rewrite the code appropriately when fixes are applied.