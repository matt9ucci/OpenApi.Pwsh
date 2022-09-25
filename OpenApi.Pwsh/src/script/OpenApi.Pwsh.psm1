using namespace OpenApi.Pwsh
using namespace OpenApi.Pwsh.Provider

param (
	[Configuration]
	$Configuration
)

if ($Configuration) {
	[Configuration]::Current = $Configuration
}

# Create an OpenApi drive if possible when the module is imported
if (![Configuration]::Current.DriveAutoCreation) {
	Write-Verbose "[Configuration]::Current.DriveAutoCreation is $([Configuration]::Current.DriveAutoCreation)."
	Write-Verbose "Skip creation of the OpenApi drive '$([Configuration]::Current.DriveName)'"
} elseif (Get-PSDrive -Name ([Configuration]::Current.DriveName) -Scope Global -ErrorAction Ignore) {
	Write-Verbose "A drive with the name '$([Configuration]::Current.DriveName)' already exists."
	Write-Verbose "Skip creation of the OpenApi drive '$([Configuration]::Current.DriveName)'"
} else {
	New-PSDrive -Name ([Configuration]::Current.DriveName) -PSProvider ([OpenApiProvider]::ProviderName) -Root '' -Scope Global
}
