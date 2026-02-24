Projects that import the Logstash formatter from this repository are currently broken because the formatter package they depend on no longer exists in the expected location. Users attempting to compile code that imports the Logstash formatter via the historical import path (e.g., `github.com/Sirupsen/logrus/formatters/logstash`) encounter build errors like “cannot find package …/formatters/logstash” or unresolved symbols.

The repository should no longer ship an internal Logstash formatter implementation. Instead, Logstash formatting support must be provided by the external replacement that now hosts the formatter and its history. The expected behavior is:

- Building this repository should succeed without any remaining internal Logstash formatter code.
- Any exported API surface related to the in-repo Logstash formatter should be removed so there is no longer an in-tree `logstash` formatter package to import.
- Users should be directed to the external repository that provides the Logstash hook/formatter, so that consumers can switch their imports to the new module and regain Logstash support.

If any code in this repository still references the old Logstash formatter types/functions, those references must be eliminated so the project compiles cleanly and does not imply the formatter is still supported here.