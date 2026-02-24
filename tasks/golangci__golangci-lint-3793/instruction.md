golangci-lint is missing support for the linter "inamedparam" (macabu/inamedparam). Users want to enable a new linter named "inamedparam" that reports problems in Go interfaces where method parameters are unnamed.

When the linter is enabled (e.g., via the standard golangci-lint enable mechanism, such as `-E inamedparam`), golangci-lint should analyze interface method signatures and emit diagnostics for each unnamed parameter. The diagnostic text must identify the interface method name and explain that the method must have named parameters.

Expected behavior:
- Interface methods with all parameters named must not produce any findings.
- Interface methods with zero parameters must not produce any findings.
- For an interface method with multiple parameters, each parameter lacking an explicit name should be reported.
- For an unnamed parameter whose type is a normal named type (including imported types like `context.Context`, built-in types like `int`/`bool`, and locally defined types like `tStruct` or an interface type like `Doer`), the message must be:
  `interface method <MethodName> must have named param for type <Type>`
  Examples:
  - `interface method WithoutName must have named param for type context.Context`
  - `interface method WithoutName must have named param for type int`
  - `interface method WithoutName must have named param for type bool`
  - `interface method WithoutName must have named param for type tStruct`
  - `interface method WithoutName must have named param for type Doer`
- For an unnamed parameter whose type is an anonymous/inline type (for example an anonymous struct type), the message must be:
  `interface method <MethodName> must have all named params`

Actual behavior:
- golangci-lint currently does not provide the `inamedparam` linter, so enabling it fails or produces no findings, and unnamed interface method parameters are not reported.

Implement the `inamedparam` linter as a first-class golangci-lint linter named exactly `inamedparam`, so that enabling it runs the underlying analysis and surfaces the diagnostics with the exact messages described above.