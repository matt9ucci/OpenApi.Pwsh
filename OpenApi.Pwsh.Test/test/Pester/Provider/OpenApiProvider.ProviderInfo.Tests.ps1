using namespace System.IO
using namespace System.Management.Automation.Provider

BeforeAll {
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	$Provider = Get-PSProvider -PSProvider ([OpenApi.Pwsh.Provider.OpenApiProvider]::ProviderName)
	$Provider | Should -HaveCount 1
	$Provider | Should -BeOfType ([System.Management.Automation.ProviderInfo])
}

Describe 'OpenApiProvider ProviderInfo' {
	It 'Name : <_>' -TestCases 'OpenApi' { $Provider.Name | Should -BeExactly $_ }
	It 'Capabilities : <_>' -TestCases (
		[ProviderCapabilities]::None
	) { $Provider.Capabilities | Should -BeExactly $_ }
	It 'Home : (empty)' { $Provider.Home | Should -BeNullOrEmpty }
	It 'VolumeSeparatedByColon : <_>' -TestCases $true { $Provider.VolumeSeparatedByColon | Should -BeExactly $_ }
	It 'ItemSeparator    : <_>' -TestCases ([Path]::DirectorySeparatorChar) { $Provider.ItemSeparator | Should -BeExactly $_ }
	It 'AltItemSeparator : <_>' -TestCases ($IsLinux -or $IsMacOS ? '\' : [Path]::AltDirectorySeparatorChar) { $Provider.AltItemSeparator | Should -BeExactly $_ }
}
