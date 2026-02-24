When a gRPC client uses PerRPCCredentials (including the JWT-based credentials in the oauth package), the URI passed to PerRPCCredentials.GetRequestMetadata is currently missing the full RPC path because the gRPC method name is stripped. This causes JWT "aud" (audience) values derived from that URI to be incomplete for systems that require the exact URL and path of the protected resource (for example, IAP-secured resources), leading to authentication failures even when the call target is correct.

The client should support both audience conventions:

1) The existing default behavior must remain: the audience/URI passed into PerRPCCredentials.GetRequestMetadata (and used for JWT audience calculation) excludes the gRPC method name.

2) A new opt-in behavior must be added, controlled by an environment variable named GRPC_AUDIENCE_IS_FULL_PATH. When this environment variable is set to true, gRPC must stop stripping the method name, and instead pass the full RPC path in the URI provided to PerRPCCredentials.GetRequestMetadata. In this mode, JWT credentials must also use the full path when computing the audience.

Concretely, when making an RPC like /grpc_testing.TestService/EmptyCall to an endpoint, the request metadata callback should receive a URI that includes the full method path (i.e., includes "/grpc_testing.TestService/EmptyCall") when GRPC_AUDIENCE_IS_FULL_PATH=true, and should receive the legacy form (with the method stripped) when the variable is unset/false.

Implement the environment-variable plumbing so it is read via the internal env configuration mechanism and affects both:
- the URI value provided to PerRPCCredentials.GetRequestMetadata
- the JWT audience computation used by the oauth JWT per-RPC credential

Expected behavior: with GRPC_AUDIENCE_IS_FULL_PATH=true, PerRPCCredentials.GetRequestMetadata is invoked with the full endpoint+RPC method in the URI, enabling JWT audiences that match exact resource URL+path requirements. With the variable unset/false, behavior remains unchanged for backward compatibility.