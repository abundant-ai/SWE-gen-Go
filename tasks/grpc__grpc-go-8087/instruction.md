Some gRPC xDS balancers need a shared way to attach and read per-endpoint weights using resolver.Endpoint attributes, but the existing helper types/functions currently live under the weightedroundrobin balancer even though they are not specific to weighted round robin. This causes awkward dependencies (e.g., ringhash needing weightedroundrobin helpers) and makes it unclear where endpoint-weight behavior is defined.

Introduce an internal package named weight that provides a small, stable API for storing and retrieving endpoint weight information on resolver.Endpoint via endpoint attributes.

The package must define:

- A struct type EndpointInfo with a field:
  - Weight uint32

- A function Set(endpoint resolver.Endpoint, info EndpointInfo) resolver.Endpoint
  - Stores info into the endpoint’s Attributes and returns the updated endpoint.
  - Must work when endpoint.Attributes is nil (it should still return an endpoint from which the info can be read back).
  - Must preserve any existing attributes on the endpoint (i.e., setting weight must not discard unrelated keys/values already present in Attributes).

- A function FromEndpoint(endpoint resolver.Endpoint) EndpointInfo
  - Reads the previously stored EndpointInfo from the endpoint’s Attributes.
  - If the endpoint has nil Attributes, or if no weight info was ever set, it must return the zero value EndpointInfo{}.

After adding this package and API, update the components that rely on endpoint weights (e.g., ringhash and xDS balancer/config logic that computes/preserves endpoint weights) so they no longer depend on weightedroundrobin-specific helpers and instead use weight.Set and weight.FromEndpoint. Code that computes ring distributions must continue to use the per-endpoint weight values and produce consistent weighted behavior.

Example expected behavior:

- Given an endpoint with existing attributes:
  - endpoint := resolver.Endpoint{Attributes: attributes.New("foo", "bar")}
  - endpoint2 := weight.Set(endpoint, weight.EndpointInfo{Weight: 100})
  - weight.FromEndpoint(endpoint2) must return weight.EndpointInfo{Weight: 100}
  - endpoint2.Attributes must still contain "foo" => "bar"

- Given an endpoint with no attributes:
  - endpoint := resolver.Endpoint{}
  - endpoint2 := weight.Set(endpoint, weight.EndpointInfo{Weight: 100})
  - weight.FromEndpoint(endpoint2) must return weight.EndpointInfo{Weight: 100}

- Given an endpoint where weight was never set:
  - weight.FromEndpoint(resolver.Endpoint{Attributes: attributes.New("foo", "bar")}) must return weight.EndpointInfo{}

Fix any compilation/runtime issues arising from moving the old helper struct(s) out of weightedroundrobin and ensure all code paths that previously consumed address/endpoint weights now use this new internal weight API consistently.