param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	$Root = 'Root'

	$DocData = @{
		Doc1 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
		Doc2 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
	}

	New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) $Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))
}

Describe 'Get-ChildItem -Name gets the child item names of' {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It 'OpenApiBasicRegistry by <Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		$names = Get-ChildItem -Name -Path $Path

		$names | Should -Be ($DocData.Keys -as [string[]])
	}

	It 'OpenApiDocument by <Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1') }
		@{ Segments = @('OpenApi:', 'Doc2') }
	) {
		$names = Get-ChildItem -Name -Path $Path

		$names | Should -Be @(
			'ExternalDocs'
			'Info'
			'Servers'
		)
		$names.PSPath | Should -Be @(
			@("OpenApi.Pwsh\OpenApi::$Root", $Segments[1], 'ExternalDocs') -join $ItemSeparator
			@("OpenApi.Pwsh\OpenApi::$Root", $Segments[1], 'Info') -join $ItemSeparator
			@("OpenApi.Pwsh\OpenApi::$Root", $Segments[1], 'Servers') -join $ItemSeparator
		)
	}
}
