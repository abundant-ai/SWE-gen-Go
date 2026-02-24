The `exhaustive` linter integration in golangci-lint has two user-visible problems.

First, golangci-lint can panic when the `exhaustive` analyzer processes certain switch statements that include case expressions referencing fields from composite variables, especially when the switched-on type comes from an imported (external) package. A minimal example looks like:

```go
package somepkg

type Enum int

const (
	EnumValue1 Enum = iota
	EnumValue2
	EnumValue3
)
```

```go
package main

import "somepkg"

type nested struct { Value somepkg.Enum }

type ext struct {
	Foo1 nested
	Foo2 nested
	Foo3 nested
	Foo4 nested
}

func check() {
	s := ext{}
	switch somepkg.EnumValue2 {
	case s.Foo1.Value, s.Foo2.Value, s.Foo3.Value:
	}
}
```

Running golangci-lint with `exhaustive` enabled should not crash. Currently it can panic with an error like:

`interface conversion: ast.Expr is *ast.SelectorExpr, not *ast.Ident`

This must be fixed so the linter reports diagnostics normally (or reports none) but never panics on this pattern.

Second, golangci-lint’s configuration support for `exhaustive` needs to be updated to match the current upstream analyzer flags. The integration must support these new settings under `linters-settings.exhaustive`:

- `ignore-enum-members` (string pattern): enum members whose names match the pattern must be excluded from the set of required cases. For example, if the enum has `North, East, South, West` and the ignore pattern matches `West`, then a switch that handles `North, South` should be reported as missing only `East`.

- `checking-strategy` (string): must accept at least `"name"` and `"value"`.
  - With strategy `"name"`, exhaustiveness is based on distinct constant names, so aliases (constants whose value equals another constant) are still required. Example: if `AccessDefault` has the same value as `AccessPublic`, a switch over the type that lists `AccessPublic` and `AccessPrivate` should still be reported as missing `AccessDefault`.
  - With strategy `"value"`, exhaustiveness is based on distinct constant values, so aliases do not need to be listed if an equivalent value is already handled. In the same example, no diagnostic should be produced.

Additionally, the old setting `ignore-pattern` must be treated as deprecated and must not affect behavior anymore; users should be required to use `ignore-enum-members` instead.

After these changes, enabling `exhaustive` should produce stable diagnostics (no panics) and the new configuration keys must correctly control which missing-case diagnostics are reported under the scenarios described above.