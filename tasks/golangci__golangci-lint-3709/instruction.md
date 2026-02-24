golangci-lint currently lacks support for the `tagalign` linter, which should enforce consistent formatting of Go struct field tags by (a) aligning tag values into columns and/or (b) sorting tag keys into a predictable order. Add support for enabling a new linter named `tagalign` so that running golangci-lint with `-E tagalign` reports issues on misformatted struct tags and suggests the corrected tag string.

When `tagalign` is enabled, it must be configurable via `linters-settings.tagalign` with the following options:

- `align` (boolean): when true, align tag spacing so that tag values line up in columns across tags within a struct field’s tag literal.
- `sort` (boolean): when true, reorder tag key/value pairs into a consistent order.
- `order` (list of strings): an optional preferred order for specific tag keys. When provided, these keys must appear first in the exact order given. Any remaining keys not mentioned in `order` must still be included after the ordered keys in a stable, deterministic way.

Expected behavior when linting code with struct tags:

1) Align + sort (default behavior unless disabled):
- For a struct field tag containing keys like `json`, `yaml`, `xml`, `binding`, `gorm`, `validate`, `zip`, the linter should produce a single suggested replacement tag string where:
  - keys are sorted into the expected order (with a consistent order across runs), and
  - spacing between adjacent tags is adjusted so values align into columns (preserving correct quoting and content).

2) Align only (`sort: false`):
- The linter must not reorder tag keys; it should only adjust spacing to align the values.
- Example: a tag like ``gorm:"column:foo" json:"foo,omitempty" xml:"foo" yaml:"foo" zip:"foo"`` should be reformatted to keep the same key sequence but add spaces so values align (e.g., extra padding after shorter entries).

3) Sort only (`align: false`, `sort: true`):
- The linter must reorder tag keys but must not insert alignment padding beyond single spaces between tags.
- Example: a tag like ``xml:"foo" json:"foo,omitempty" yaml:"foo" gorm:"column:foo" validate:"required" zip:"foo"`` should be reordered into the canonical sorted order (e.g., starting with `gorm`, then `json`, then `validate`, then `xml`, `yaml`, `zip`).

4) Custom order only (`align: false`, with `order: ["xml","json","yaml"]`):
- The linter must reorder tags so that `xml`, `json`, `yaml` appear first in that exact order, followed by the remaining keys afterward deterministically.

The reported diagnostic should include the exact expected corrected struct tag literal (the full backquoted string content) so users can update the tag to the suggested value. The linter must handle tags with irregular spacing (including leading spaces inside the backquotes) and still produce the normalized output. It must also handle nested/embedded struct fields that have their own tags and avoid crashing on fields without tags.

Implement the `tagalign` linter integration so these behaviors are respected based on configuration, and ensure it can be enabled/disabled like other linters through golangci-lint configuration and flags.