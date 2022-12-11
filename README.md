# OpenApi.Pwsh

## Usage

### Import, edit, and export an OpenAPI document

```powershell
# Import OpenAPI document from local
Import-OpenApiDocument $HOME\petstore.json
# If from remote
# Import-OpenApiDocument -Uri https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v3.0/petstore.json

# Get the doc by name (default: the imported file name)
$doc = Get-OpenApiDocument petstore

# Edit the doc
$doc.Info = @{
	Version = '0.1.0'
	Title   = 'New Title'
}

# Export the doc as JSON file
Convert-OpenApiDocument $doc | Out-File -FilePath $HOME\petstore-new.json
```

### Import and invoke an OpenAPI document

```powershell
# Import OpenAPI document
Import-OpenApiDocument $HOME\example.json

# Build the parameters of Invoke-RestMethod cmdlet (alias: irm)
# in order to invoke the 'GetUser' API defined in the example.json
$params = Build-IrmParam example GetUser -id abcd
# It is the same as:
# $params = Build-IrmParam -OpenApiName example -OperationId GetUser -id abcd

# Show the parameters
$params
# @{
# 	Uri = [uri]::new('https://example.com/users/abcd')
# 	Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
# }

# Invoke the API by splatting
Invoke-RestMethod @params

# Invoke the API by splatting and additional parameters
Invoke-RestMethod @params -StatusCodeVariable statusCode -SkipHttpErrorCheck
# Show the statusCode
"StatusCode = $statusCode"
```

### Create an OpenAPI document with OpenAPI.NET SDK

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

$paths = $doc.Paths

$paths['/users/{id}'] = @{}
$paths['/users/{id}'].Operations['Get'] = @{ OperationId = 'GetUser' }
$paths['/users/{id}'].Operations['Get'].Parameters.AddRange([OpenApiParameter[]]@(
	@{ In = 'Path';  Name = 'id';      Schema = @{ Type = 'string' }; Required = $true }
	@{ In = 'Query'; Name = 'timeout'; Schema = @{ Type = 'integer' } }
))
$paths['/users/{id}'].Operations['Get'].Responses.Add(200, @{
	Description = 'GetUser Response 200 Description'
})
```
