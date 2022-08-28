using namespace System.Diagnostics.CodeAnalysis

param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe '<TestPath>' -ForEach @(
	@{ TestPath = { Test-Path -Path $Path } }
	@{ TestPath = { Test-Path -LiteralPath $Path } }
	@{ TestPath = { $Path | Test-Path } }
) {
	BeforeDiscovery {
		$ExistTestCases_Main = @(
			@{ Segments = @('OpenApi:') }
			@{ Segments = @('OpenApi:', 'Doc') }
			@{ Segments = @('OpenApi:', 'Doc', 'ExternalDocs') }
			@{ Segments = @('OpenApi:', 'Doc', 'Info') }
			@{ Segments = @('OpenApi:', 'Doc', 'Info', 'Contact') }
			@{ Segments = @('OpenApi:', 'Doc', 'Info', 'License') }
			@{ Segments = @('OpenApi:', 'Doc', 'Servers') }
			@{ Segments = @('OpenApi:', 'Doc', 'Servers', '0') }
			@{ Segments = @('OpenApi:', 'Doc', 'Servers', '1') }
		)

		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$ExistTestCases_Main_Root = foreach ($case in $ExistTestCases_Main) {
			@{
				Segments = @(
					$case['Segments'][0]
					'Root'
					$case['Segments'][1..$case['Segments'].Length]
				)
			}
		}
	}

	BeforeAll {
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) 'Root' -OpenApiRegistry (
			[OpenApiBasicRegistry]@{
				Doc = & $PSScriptRoot\..\New-OpenApiDocument.ps1
			}
		)
	}

	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It 'True <Path>' -TestCases @(
		$ExistTestCases_Main
		$ExistTestCases_Main_Root
		foreach ($case in $ExistTestCases_Main) { @{ Segments = $case['Segments'].ToUpper() } }
		foreach ($case in $ExistTestCases_Main) { @{ Segments = $case['Segments'].ToLower() } }
	) {
		Test-Path -Path $Path | Should -BeTrue
	}

	It 'False <Path>' -TestCases @(
		foreach ($case in $ExistTestCases_Main) { @{ Segments = $case['Segments'] + 'NotExist' } }
		@{ Segments = $ExistTestCases_Main_Root[0]['Segments'].ToUpper() } # Root is case-sensitive
		@{ Segments = $ExistTestCases_Main_Root[0]['Segments'].ToLower() } # Root is case-sensitive
	) {
		Test-Path -Path $Path | Should -BeFalse
	}
}
