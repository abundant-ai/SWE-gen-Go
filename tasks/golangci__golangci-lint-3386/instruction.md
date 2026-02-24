A new linter named "musttag" needs to be supported. This linter enforces that exported struct fields used in marshaling/unmarshaling calls have the appropriate struct tag.

When musttag is enabled and code calls JSON marshal/unmarshal functions, any exported field in the involved struct type that lacks the required tag should produce a diagnostic with the exact message:

`exported fields should be annotated with the "json" tag`

For example, given an anonymous struct with exported fields like `Name string` and `Email string `json:"email"`` passed to `json.Marshal(user)` or referenced via `json.Unmarshal(..., &user)`, the `Name` field is missing the json tag and should trigger the above diagnostic.

The linter must also support configuring additional (or overridden) target functions via configuration under `linters-settings.musttag.functions`. Each entry provides:
- `name`: fully-qualified function name (e.g., `encoding/asn1.Marshal`, `encoding/asn1.Unmarshal`)
- `tag`: required struct tag key (e.g., `asn1`)
- `arg-pos`: which argument position contains the value or pointer to the value whose struct fields must be checked

With such configuration present, calls to the configured functions must be checked similarly. For example, when configured for `encoding/asn1.Marshal` (arg-pos 0, tag "asn1") and `encoding/asn1.Unmarshal` (arg-pos 1, tag "asn1"), passing a struct value to `asn1.Marshal(user)` or passing `&user` as the second argument to `asn1.Unmarshal(nil, &user)` should require exported fields to have an `asn1` tag; if any exported field is missing it, a diagnostic must be emitted with the exact message:

`exported fields should be annotated with the "asn1" tag`

Behavior must work for both built-in support (at least for `encoding/json.Marshal` and `encoding/json.Unmarshal` with required tag "json") and for the custom configured functions in `linters-settings.musttag.functions`.

The musttag linter must be discoverable/enableable through the usual linter enable mechanism (e.g., enabling "musttag" should run it) and must honor configuration so that the custom function list is applied when provided.