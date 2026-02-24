Gin currently provides helpers like Context.File() and router-level static file serving, but it’s missing a way to serve a single file directly from an arbitrary http.FileSystem at request time. This prevents common use cases like serving an alias file without redirecting, returning a help page for the root of an /api/ group without manually opening/streaming the file, and selecting the backing FileSystem dynamically per request.

Implement a new Context method named FileFromFS that serves a specific file from a provided http.FileSystem.

When calling c.FileFromFS(filepath, fs), Gin should locate and open the given filepath using the supplied fs (via fs.Open), and then write the file to the response using the same semantics as existing file-serving helpers: it should stream the content as an HTTP response, set appropriate headers (including Content-Type inference and other standard file-serving headers), and honor standard net/http behavior for file serving (e.g., support for range requests / conditional requests as applicable).

If the file does not exist or cannot be opened from the given http.FileSystem, FileFromFS should not panic; it should respond with an appropriate HTTP error (e.g., 404 for not found) consistent with Gin’s existing file-serving behavior.

The method must not issue redirects; it should serve the content directly from the given filesystem. It must also work correctly when the FileSystem is chosen dynamically during a request (i.e., per-handler call).