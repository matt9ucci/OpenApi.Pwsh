param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe '<ClearItem>' -ForEach @(
	@{ ClearItem = { Clear-Item -Path $Path } }
	@{ ClearItem = { Clear-Item -LiteralPath $Path } }
	@{ ClearItem = { $Path | Clear-Item } }
	@{ ClearItem = { [pscustomobject]@{ Path = $Path } | Clear-Item } }
) {
	BeforeAll {
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root
	}

	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator

		Set-Item -Path OpenApi:Doc1 -Value (& $PSScriptRoot\..\New-OpenApiDocument.ps1)
		Set-Item -Path OpenApi:Doc2 -Value (& $PSScriptRoot\..\New-OpenApiDocument.ps1)
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1') }
		@{ Segments = @('OpenApi:', 'Doc1', 'ExternalDocs') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'Contact') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'License') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '1') }
	) {
		Test-Path -Path $Path | Should -BeTrue
		& $ClearItem
		Test-Path -Path $Path | Should -BeFalse
	}
}

Describe 'Clear-Item -Path wildcard' {
	BeforeAll {
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root
	}

	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator

		Set-Item -Path OpenApi:Doc1 -Value (& $PSScriptRoot\..\New-OpenApiDocument.ps1)
		Set-Item -Path OpenApi:Doc2 -Value (& $PSScriptRoot\..\New-OpenApiDocument.ps1)
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'D*') }
		@{ Segments = @('OpenApi:', '*[12]') }
		@{ Segments = @('OpenApi:', 'Doc?') }
		@{ Segments = @('OpenApi:', 'Doc?', 'ExternalDocs') }
		@{ Segments = @('OpenApi:', 'Doc?', 'Info') }
		@{ Segments = @('OpenApi:', 'Doc?', 'Info', 'Contact') }
		@{ Segments = @('OpenApi:', 'Doc?', 'Info', 'License') }
		@{ Segments = @('OpenApi:', 'Doc?', 'Servers') }
		@{ Segments = @('OpenApi:', 'Doc?', 'Servers', '1') }
	) {
		(Get-Item -Path $Path).Count | Should -BeGreaterThan 0
		Clear-Item -Path $Path
		(Get-Item -Path $Path).Count | Should -Be 0
	}
}

Describe 'Clear-Item exceptions' {
	BeforeAll {
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root
	}

	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator

		Set-Item -Path OpenApi:Doc1 -Value (& $PSScriptRoot\..\New-OpenApiDocument.ps1)
		Set-Item -Path OpenApi:Doc2 -Value (& $PSScriptRoot\..\New-OpenApiDocument.ps1)
	}

	It 'cannot clear <Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
	) {
		{
			Clear-Item -Path $Path -ErrorAction Stop
		} | Should -ExceptionType ([PSArgumentException])
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
			Clear-Item -Path $Path -ErrorAction Stop
		} | Should -ExceptionType ([ItemNotFoundException])
	}
}
