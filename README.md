# OpenApi.Pwsh

```powershell
using namespace System.Collections.Generic
using namespace Microsoft.OpenApi.Models

$doc = [OpenApiDocument]@{
	Info    = [OpenApiInfo]@{
		Version = '0.1.0'
		Title   = 'Info Title'
	}
	Servers = [List[OpenApiServer]]@(
		@{ Url = 'https://example.com/Servers/0' }
		@{ Url = 'https://example.com/Servers/1' }
	)
	Paths   = [OpenApiPaths]::new()
}

$doc.Paths.Add('/path01', [OpenApiPathItem]::new())
$doc.Paths['/path01'].Operations.Add('Get', [OpenApiOperation]@{
	Description = 'Get /path01 Description'
})
$doc.Paths['/path01'].Operations['Get'].Responses.Add(200, [OpenApiResponse]@{
	Description = 'Get /path01 Response 200 Description'
})
```
