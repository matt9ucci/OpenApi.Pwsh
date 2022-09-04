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
	@{ GetChildItem = { Get-ChildItem -Depth 0 -Path $Path } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		Test-GetChildItem -Expected @(
			$DocData.Values
		)
	}
}

Describe '<GetChildItem>' -ForEach @(
	@{ GetChildItem = { Get-ChildItem -Depth 1 -Path $Path } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		Test-GetChildItem -Expected @(
			$DocData.Values
			foreach ($doc in $DocData.Values.GetEnumerator()) {
				$doc.ExternalDocs
				$doc.Info
				@(, $doc.Servers)
			}
		)
	}
}

Describe '<GetChildItem>' -ForEach @(
	@{ GetChildItem = { Get-ChildItem -Depth 2 -Path $Path } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		Test-GetChildItem -Expected @(
			$DocData.Values
			foreach ($doc in $DocData.Values.GetEnumerator()) {
				$doc.ExternalDocs
				$doc.Info
				$doc.Info.Contact
				$doc.Info.License
				@(, $doc.Servers)
				$doc.Servers[0]
				$doc.Servers[1]
			}
		)
	}
}
