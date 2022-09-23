@{
ModuleVersion = '0.4.0'
Description   = 'Import, edit, and invoke OpenAPI documents.'

NestedModules = @(
	'OpenApi.Pwsh.dll'
)
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
	ReleaseNotes = @'
New provider cmdlets:
* Clear-Item
* Remove-Item
* Clear-Content
* Get-Content
* Set-Content
'@
}}

GUID = '3063FF81-7DFA-4601-9CD9-4F74FE746D8C'

Author    = 'Masatoshi Higuchi'
Copyright = '(c) Masatoshi Higuchi.'
}
