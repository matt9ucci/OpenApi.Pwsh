@{
ModuleVersion = '0.7.0'
Description   = 'Import, edit, and invoke OpenAPI documents.'

RootModule = 'OpenApi.Pwsh.psm1'
NestedModules = @(
	'OpenApi.Pwsh.dll'
)
RequiredAssemblies = @(
	'Microsoft.OpenApi.dll'
	'Microsoft.OpenApi.Readers.dll'
	# Lazy loading
	# 'SharpYaml.dll'
	# 'Tavis.UriTemplates.dll'
)

PowerShellVersion = '7.2'

CmdletsToExport = @(
	'Build-IrmParam'
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
* New cmdlet: Build-IrmParam
* Add Tavis.UriTemplates as an RFC 6570 URI template processor
'@
}}

GUID = '3063FF81-7DFA-4601-9CD9-4F74FE746D8C'

Author    = 'Masatoshi Higuchi'
Copyright = '(c) Masatoshi Higuchi.'
}
