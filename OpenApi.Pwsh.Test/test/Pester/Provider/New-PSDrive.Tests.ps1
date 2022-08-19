BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe 'New-PSDrive -Name <Name> -Root ''<Root>''' -ForEach @(
	@{ Name = 'OpenApi'; Root = [string]::Empty }
	@{ Name = 'OpenApi'; Root = 'NotEmpty' }
) {
	BeforeEach {
		$Drive = New-PSDrive -Name $Name -PSProvider ([OpenApiProvider]::ProviderName) -Root $Root
		$Drive | Should -HaveCount 1
		$Drive | Should -BeOfType ([PSDriveInfo])
	}

	It 'creates a drive ''<Name>''' {
		$Drive.Name | Should -BeExactly $Name

		$Drive.Provider.Name | Should -BeExactly ([OpenApiProvider]::ProviderName)
		$Drive.VolumeSeparatedByColon | Should -BeTrue
		$Drive.CurrentLocation | Should -BeNullOrEmpty
	}

	if ($Root) {
		It 'sets the drive''s Root ''<Root>''' {
			$Drive.Root | Should -BeExactly $Root
		}
	} else {
		It 'sets the drive''s Root ''OpenApiBasicRegistry'' (default OpenApiRegistry name)' {
			$Drive.Root | Should -BeExactly OpenApiBasicRegistry
		}
	}
}
