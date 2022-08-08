@{
ModuleVersion = '0.1.0'
Description   = 'Import, edit, and invoke OpenAPI documents.'

RequiredAssemblies = @(
	'Microsoft.OpenApi.dll'
	'Microsoft.OpenApi.Readers.dll'
	'SharpYaml.dll'
)

PowerShellVersion = '7.2'

PrivateData = @{ PSData = @{
	ProjectUri   = 'https://github.com/matt9ucci/OpenApi.Pwsh'
	LicenseUri   = 'https://github.com/matt9ucci/OpenApi.Pwsh/blob/master/LICENSE'
	Tags         = @('OpenAPI', 'Swagger')
	ReleaseNotes = 'OpenAPI.NET 1.3.2 is available in PowerShell session.'
}}

GUID = '3063FF81-7DFA-4601-9CD9-4F74FE746D8C'

Author    = 'Masatoshi Higuchi'
Copyright = '(c) Masatoshi Higuchi.'
}
