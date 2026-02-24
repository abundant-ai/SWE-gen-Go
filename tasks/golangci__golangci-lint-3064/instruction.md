Add support for a new linter named `reassign` that reports assignments to exported/global variables defined in *other packages* (e.g., `io.EOF = nil`). When the linter is enabled, it should emit a diagnostic whenever code reassigns a variable owned by an imported package.

For example, given:

```go
import (
  "io"
  "net/http"
)

func f() {
  http.DefaultClient = nil
  http.DefaultTransport = nil
  io.EOF = nil
}
```

The linter must report an issue for `io.EOF = nil` with the message:

`reassigning variable EOF in other package io`

The linter must also support configuration to restrict which variable names are checked. When configured with a list of `patterns` such as:

```yaml
linters-settings:
  reassign:
    patterns:
      - DefaultClient
      - DefaultTransport
```

then only reassignments whose variable name matches one of the configured patterns should be reported. Under this configuration, `http.DefaultClient = nil` and `http.DefaultTransport = nil` must be reported with messages:

`reassigning variable DefaultClient in other package http`

`reassigning variable DefaultTransport in other package http`

and `io.EOF = nil` must not be reported.

The `reassign` linter should be enableable via the standard linter enable mechanism (e.g., `-Ereassign`) and should work with default settings (no patterns configured) by reporting reassignments to variables in other packages.