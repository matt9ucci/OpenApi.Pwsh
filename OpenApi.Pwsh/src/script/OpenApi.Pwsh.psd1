@{
ModuleVersion = '0.6.0'
Description   = 'Import, edit, and invoke OpenAPI documents.'

RootModule = 'OpenApi.Pwsh.psm1'
NestedModules = @(
	'OpenApi.Pwsh.dll'
)
RequiredAssemblies = @(
	'Microsoft.OpenApi.dll'
	'Microsoft.OpenApi.Readers.dll'
	'SharpYaml.dll'
)

PowerShellVersion = '7.2'

CmdletsToExport = @(
	'Convert-OpenApiDocument'
	'Get-OpenApiDocument'
	'Import-OpenApiDocument'
	'Show-OpenApiExternalDocs'
)

PrivateData = @{ PSData = @{
	ProjectUri   = 'https://github.com/matt9ucci/OpenApi.Pwsh'
	LicenseUri   = 'https://github.com/matt9ucci/OpenApi.Pwsh/blob/master/LICENSE'
	Tags         = @('OpenAPI', 'Swagger')
	ReleaseNotes = @'
* Update Microsoft.OpenApi to 1.4.4
* New cmdlet: Show-OpenApiExternalDocs
* New completers: OpenApiName, OperationId
'@
}}

GUID = '3063FF81-7DFA-4601-9CD9-4F74FE746D8C'

Author    = 'Masatoshi Higuchi'
Copyright = '(c) Masatoshi Higuchi.'
}
