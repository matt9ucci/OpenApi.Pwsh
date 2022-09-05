using namespace System.Diagnostics.CodeAnalysis

param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	function Test-GetItem {
		param (
			[Parameter(Mandatory)]
			$Expected
		)

		$actual = & $GetItem

		$actual | Should -Be $Expected
		$actual.PSPath | Should -BeExactly (
			@(
				"OpenApi.Pwsh\OpenApi::$Root"
				$Segments[1..$Segments.Length]
			) -join $ItemSeparator
		)
	}

	$Root = 'Root'

	$DocData = @{
		Doc1 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
		Doc2 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
	}

	$Registry = [OpenApiBasicRegistry]::new($DocData)

	New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) $Root -OpenApiRegistry $Registry
}

Describe '<GetItem>' -ForEach @(
	@{ GetItem = { Get-Item -Path $Path -ErrorAction Stop } }
	@{ GetItem = { Get-Item -LiteralPath $Path -ErrorAction Stop } }
	@{ GetItem = { $Path | Get-Item -ErrorAction Stop } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		Test-GetItem -Expected $Registry
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1') }
	) {
		Test-GetItem -Expected $DocData[$Segments[1]]
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'ExternalDocs') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers') }
	) {
		Test-GetItem -Expected $DocData[$Segments[1]].($Segments[2])
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'Contact') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'License') }
	) {
		Test-GetItem -Expected $DocData[$Segments[1]].($Segments[2]).($Segments[3])
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '0') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '1') }
	) {
		Test-GetItem -Expected $DocData[$Segments[1]].($Segments[2])[$Segments[3]]
	}

	It 'Not found <Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'ExternalDocs', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '2') }
	) {
		{
			& $GetItem
		} | Should -ExceptionType ([ItemNotFoundException])
	}
}

Describe 'Get-Item -Path wildcard' {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'D*') }
		@{ Segments = @('OpenApi:', 'Doc?') }
		@{ Segments = @('OpenApi:', '*[12]') }
	) {
		$docs = Get-Item -Path $Path

		$docs | Should -BeOfType ([OpenApiDocument])
		$docs.PSPath | Sort-Object | Should -BeExactly @(
			(@("OpenApi.Pwsh\OpenApi::$Root", 'Doc1') -join $ItemSeparator)
			(@("OpenApi.Pwsh\OpenApi::$Root", 'Doc2') -join $ItemSeparator)
		)
	}
}
