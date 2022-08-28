using namespace System.Collections.Generic
using namespace Microsoft.OpenApi.Models

[OpenApiDocument]@{
	ExternalDocs = [OpenApiExternalDocs]::new()
	Info         = [OpenApiInfo]@{
		Contact = [OpenApiContact]::new()
		License = [OpenApiLicense]::new()
	}
	Servers      = [List[OpenApiServer]]@(
		[OpenApiServer]::new()
		[OpenApiServer]::new()
	)
}
