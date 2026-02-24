The gci linter integration mishandles section configuration and has incorrect defaults.

When enabling the gci linter, users can configure the import grouping order via a `sections` setting under `linters-settings.gci`. The integration should pass these sections through to gci so that imports are grouped and separated exactly according to the configured section list (including support for `prefix(<module>)` entries).

Currently there are two problems:

1) The default section list is inverted/incorrect. If the user does not specify `linters-settings.gci.sections`, the default behavior should match gci’s intended defaults, which are `[]string{"standard", "default"}` (in that order). The current integration uses the opposite order, which causes imports to be grouped incorrectly.

2) Even when users explicitly configure sections, the integration does not correctly support the configurable section functionality introduced in newer gci versions. For example, with this configuration:

```yaml
linters-settings:
  gci:
    sections:
      - standard
      - prefix(github.com/golangci/golangci-lint)
      - default
```

a file whose imports include:

```go
import (
    "fmt"

    "github.com/golangci/golangci-lint/pkg/config"
    "github.com/pkg/errors"
)
```

should be reported as improperly formatted because `github.com/pkg/errors` must be separated into the `default` section, while `github.com/golangci/golangci-lint/pkg/config` belongs to the configured `prefix(...)` section. The linter run should produce an issue indicating gci formatting is wrong (e.g., an error about unexpected whitespace/newlines at the import boundary) when the sections are not respected.

Fix the gci integration so that:
- The default sections order is `standard` then `default`.
- The `sections` configuration is honored and supports `prefix(...)` entries.
- Running golangci-lint with `-Egci` and a YAML config specifying sections produces issues when imports are not grouped according to the configured order, and does not mis-group imports due to inverted defaults.