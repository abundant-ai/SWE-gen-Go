TextFormatter currently emits logfmt output with hard-coded key names for its built-in fields (notably the message and level fields). This is a problem for log aggregation/parsing services that expect specific field names (for example, they may only recognize keys literally named "message" and "level"), and it also makes TextFormatter inconsistent with JSONFormatter, which already supports remapping these built-in field keys via FieldMap.

Extend TextFormatter to support the same FieldMap customization used by JSONFormatter. When a TextFormatter has FieldMap set, its output should use the mapped key names for the built-in fields it emits (at minimum: time, level, and message). For example, if the FieldMap maps the built-in level field to "severity", then TextFormatter output should include "severity=info" (or the corresponding level), not "level=info". Likewise, if the built-in message field is mapped, the emitted key should change accordingly.

This customization must not change any other logfmt encoding behavior: quoting and escaping rules should remain the same, custom user fields (added via WithField/WithFields) should still be emitted as before, and timestamp formatting (including TimestampFormat) should continue to work. If FieldMap is nil or does not contain an entry for a built-in field, TextFormatter should fall back to its existing default key names so existing output remains unchanged by default.

Reproduction example:
- Create a TextFormatter with DisableColors enabled.
- Set a FieldMap that remaps the built-in keys (e.g., level -> "severity", msg/message -> "message").
- Format an entry with a custom field.
Expected: the output contains the remapped built-in keys (e.g., "severity=..." and the remapped message key) while preserving the logfmt structure, quoting/escaping, and including any custom fields.
Actual (current): built-in keys remain hard-coded (e.g., "level=" is always used), preventing integration with services that require different key names.