param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	function Test-GetChildItem {
		param (
			[Parameter(Mandatory)]
			$Expected
		)

		$actual = & $GetChildItem

		foreach ($a in $actual) {
			@(, $a) | Should -BeIn $Expected
			$a.PSPath | Should -Be (
				@(
					"OpenApi.Pwsh\OpenApi::$Root"
					$Segments[1..($Segments.Length)]
					$a.PSChildName
				) -join $ItemSeparator
			)
		}
	}

	$Root = 'Root'

	$DocData = @{
		Doc1 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
		Doc2 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
	}

	New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) $Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))
}

Describe '<GetChildItem>' -ForEach @(
	@{ GetChildItem = { Get-ChildItem -Path $Path -ErrorAction Stop } }
	@{ GetChildItem = { Get-ChildItem -LiteralPath $Path -ErrorAction Stop } }
	@{ GetChildItem = { $Path | Get-ChildItem -ErrorAction Stop } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		Test-GetChildItem -Expected @($DocData.Values)
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1') }
	) {
		Test-GetChildItem -Expected @(
			$DocData[$Segments[1]].ExternalDocs
			$DocData[$Segments[1]].Info
			@(, $DocData[$Segments[1]].Servers)
		)
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'Info') }
	) {
		Test-GetChildItem -Expected @(
			$DocData[$Segments[1]].($Segments[2]).Contact
			$DocData[$Segments[1]].($Segments[2]).License
		)
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers') }
	) {
		Test-GetChildItem -Expected @(
			$DocData[$Segments[1]].($Segments[2])
		)
	}

	It 'Not found <Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '2') }
	) {
		{
			& $GetChildItem
		} | Should -ExceptionType ([ItemNotFoundException])
	}
}
