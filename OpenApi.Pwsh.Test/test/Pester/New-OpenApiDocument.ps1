using namespace System.Collections.Generic
using namespace Microsoft.OpenApi.Models

[OpenApiDocument]@{
	ExternalDocs = [OpenApiExternalDocs]::new()
	Info         = [OpenApiInfo]@{
		Contact = [OpenApiContact]::new()
		License = [OpenApiLicense]::new()
	}
	Servers = [List[OpenApiServer]]@(
		[OpenApiServer]@{
			Url = 'https://example.com/Servers/0/Url'
		}
		[OpenApiServer]@{
			Url = 'https://example.com/Servers/1/Url'
		}
	)
}
