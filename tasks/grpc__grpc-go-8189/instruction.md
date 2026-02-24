The `resolver.EndpointMap` type needs to be converted to a generic container so callers can store strongly-typed values without using `any` and type assertions.

Currently, code that wants to associate per-endpoint state must store values as untyped interface values, which forces unsafe casts and makes it easy to introduce runtime panics or incorrect behavior. Update the API so users can create a typed endpoint map, e.g.:

```go
m := resolver.NewEndpointMap[*endpointState]()
m.Set(ep, &endpointState{...})

st, ok := m.Get(ep) // st has type *endpointState
```

The generic `EndpointMap[T]` must support the existing core operations used throughout the codebase:
- Construction via `NewEndpointMap[T]()`.
- `Set(endpoint, value)` to associate a value with an endpoint.
- `Get(endpoint)` returning `(value, ok)` where `value` is of type `T` and `ok` indicates presence.
- `Delete(endpoint)` to remove an entry.
- `Len()` returning the number of stored entries.
- Iteration over entries (where used) must expose values with the correct type `T`.

Endpoint identity must remain consistent with existing endpoint equality semantics (i.e., endpoints that should be considered the same key must still collide as the same key, and endpoints that differ in meaningful fields must not). After the change, existing components that depend on endpoint-to-state mappings (for example, ring-hash load balancing that builds rings from a map of `resolver.Endpoint` to per-endpoint state) should compile and behave the same, but without any `any` storage or type assertions.

If `EndpointMap` was previously used indirectly via other map-like helpers or aliases, those must be updated to work with the new generic type so that callers can store typed values end-to-end. The end result should be that code can maintain endpoint state using `*resolver.EndpointMap[*endpointState]` (and other concrete types) without losing type safety, and without changing the externally observable behavior of endpoint selection/ring construction.