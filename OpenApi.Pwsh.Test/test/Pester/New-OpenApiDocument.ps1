using namespace System.Collections.Generic
using namespace Microsoft.OpenApi.Models

$doc = [OpenApiDocument]@{
	ExternalDocs = [OpenApiExternalDocs]@{
		Description = 'ExternalDocs Description'
		Url         = 'https://example.com/ExternalDocs/Url'
	}
	Info         = [OpenApiInfo]@{
		Contact = [OpenApiContact]::new()
		License = [OpenApiLicense]::new()
	}
	Paths        = [OpenApiPaths]::new()
	Servers      = [List[OpenApiServer]]@(
		[OpenApiServer]@{
			Url = 'https://example.com/Servers/0/Url'
		}
		[OpenApiServer]@{
			Url = 'https://example.com/Servers/1/Url'
		}
	)
}

$doc.Paths.Add('/path01', [OpenApiPathItem]::new())
$doc.Paths['/path01'].Operations.Add([OperationType]::Get, [OpenApiOperation]@{
	Description  = 'Get /path01 Description'
	ExternalDocs = [OpenApiExternalDocs]@{
		Description = 'Get /path01 ExternalDocs Description'
		Url         = 'https://example.com/Get/path01/ExternalDocs/Url'
	}
	OperationId = 'path01'
})

$doc
