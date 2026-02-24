Add a new golangci-lint analyzer named `nosprintfhostport` that reports uses of `fmt.Sprintf` (and equivalent formatting helpers used via `fmt`) to construct a URL containing a `host:port` segment directly in the format string, because this breaks when `host` is an IPv6 literal (it must be bracketed). The linter should emit the exact diagnostic message:

`host:port in url should be constructed with net.JoinHostPort and not directly with fmt.Sprintf`

The linter should trigger when the format string looks like a URL with a scheme (including schemes with `+` or digits after the first character such as `telnet+ssl` and `weird3.6`) followed by `://`, and then includes a host placeholder followed by a colon and a port placeholder/value in the authority part, such as:

- `fmt.Sprintf("https://%s:%d", host, port)`
- `fmt.Sprintf("https://%s:9211", host)`
- `fmt.Sprintf("https://user@%s:%d", host, port)`
- `fmt.Sprintf("postgres://%s:%s@%s:5050/%s", user, pass, host, db)`
- `fmt.Sprintf("gopher://%s:%d", host, port)`
- `fmt.Sprintf("telnet+ssl://%s:%d", host, port)`
- `fmt.Sprintf("http://%s:1936/healthz", ip)`

The linter should not report cases where:

- There is no `host:port` being formed in a URL authority (e.g., `"http://api.%s/foo"`, or `"http://api.%s:6443/foo"` where the colon is part of a fixed hostname pattern rather than `host:port` construction).
- The code already uses `net.JoinHostPort(host, port)` to create the host:port string (including when that result is substituted into a URL with `%s`).
- The string is not a valid URL scheme prefix (e.g., a scheme starting with a digit like `"9invalidscheme://..."` should not be considered a URL and should not be reported).
- A colon appears later in the path or other non-authority portions (e.g., `"http://%s/foo:bar"` should not be reported when `%s` is already a `net.JoinHostPort(...)` result).

Once implemented and wired into golangci-lint, enabling `nosprintfhostport` should cause golangci-lint to flag the problematic `fmt.Sprintf` URL constructions above with the exact message, and remain silent for the allowed patterns.