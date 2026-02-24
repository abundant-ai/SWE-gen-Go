The Sentry hook for logrus does not currently capture HTTP request details when a user attaches an *http.Request to a log entry. Users want to be able to include request context in Sentry by adding a request object under the structured field name "http_request".

When logging with something like:

```go
req, _ := http.NewRequest("GET", "url", nil)
logger.WithFields(logrus.Fields{
  "server_name":  "testserver.internal",
  "logger":       "test.logger",
  "http_request": req,
}).Error("error message")
```

the Sentry hook should recognize that the value associated with the "http_request" field is an *http.Request and attach a corresponding Sentry HTTP interface to the outgoing Sentry packet (i.e., send detailed request information derived from that *http.Request, following Sentry's HTTP interface expectations).

In addition to the request handling, existing "special fields" must continue to work: when the log entry contains "logger" it should set the Sentry packet's Logger field to that value, and when it contains "server_name" it should set the Sentry packet's ServerName field to that value. Logging an error without any special fields should still produce a Sentry packet whose Message matches the log message.

Implement the special handling in the Sentry hook so that providing an *http.Request under "http_request" results in request details being included in the sent packet rather than being ignored or treated as a generic extra field.
