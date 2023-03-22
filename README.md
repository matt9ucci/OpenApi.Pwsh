# OpenApi.Pwsh

This module provides the cmdlets to import, edit, and invoke OpenAPI documents.
The cmdlets heavily depend on [microsoft/OpenAPI.NET](https://github.com/microsoft/OpenAPI.NET), supporting OpenAPI Specification (OAS) [v2](https://spec.openapis.org/oas/v2.0) and [v3](https://spec.openapis.org/oas/v3.0.0).
You can also use the classes of OpenAPI.NET in your PowerShell session.

## Requirements

PowerShell 7.2 or higher.

## Installation

```powershell
# Install from PowerShell Gallery
Install-Module OpenApi.Pwsh
# Import
Import-Module OpenApi.Pwsh
```

Don't forget to execute the `Import-Module` command every time you start a new PowerShell session.
You can do it automatically with [PowerShell profile](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles).

## Usage

For information about the cmdlets of this module, see [about_OpenApi.Pwsh](https://github.com/matt9ucci/about_OpenApi.Pwsh).

If you want to create an OpenAPI document with OpenAPI.NET classes, see the following example:

```powershell
using namespace System.Collections.Generic
using namespace Microsoft.OpenApi.Models

$doc = [OpenApiDocument]@{
	Info = @{
		Version = '0.1.0'
		Title   = 'Info Title'
		License = @{
			Name = 'MIT License'
			Url  = 'https://spdx.org/licenses/MIT.html'
		}
	}
	ExternalDocs = @{
		Description = 'ExternalDocs Description'
		Url         = 'https://example.com/ExternalDocs/Url'
	}
	Servers = [List[OpenApiServer]]@(
		@{ Url = 'https://example.com/Servers/0/Url' }
		@{ Url = 'https://example.com/Servers/1/Url' }
	)
	Paths = [OpenApiPaths]::new()
}

$doc.Paths.Add('/users/{id}', [OpenApiPathItem]::new())
$doc.Paths['/users/{id}'].Operations.Add('Get', @{
	Description  = 'Get /users/{id} Description'
	ExternalDocs = @{
		Description = 'Get /users/{id} ExternalDocs Description'
		Url         = 'https://example.com/Get/users/{id}/ExternalDocs/Url'
	}
	OperationId = 'GetUser'
})

$doc | Convert-OpenApiDocument
<# output
{
  "openapi": "3.0.1",
  "info": {
    "title": "Info Title",
    "license": {
      "name": "MIT License",
      "url": "https://spdx.org/licenses/MIT.html"
    },
    "version": "0.1.0"
  },
  "servers": [
...
#>
```
