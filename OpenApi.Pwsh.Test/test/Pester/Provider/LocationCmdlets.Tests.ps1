using namespace System.Diagnostics.CodeAnalysis

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

BeforeDiscovery {
	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$testCases = @(
		@{ Segments = @('OpenApi:') }
		@{ Segments = @('OpenApi:', 'Doc1') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers') }
	)

	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$testCases_NotFound = @(
		@{ Segments = @('OpenApi:', 'NotFound') }
		@{ Segments = @('OpenApi:', 'Doc1', 'ExternalDocs') }
	)
}

Describe 'Set-Location then Get-Location' {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
		Push-Location -StackName BeforeEach
	}

	AfterEach {
		Pop-Location -StackName BeforeEach
	}

	It '<Path>' -TestCases $testCases {
		Set-Location -Path $Path
		$location = Get-Location

		if ($location.Path.EndsWith($ItemSeparator)) {
			# OpenApi:\
			$location | Should -BeExactly ($Path + $ItemSeparator)
		} else {
			$location | Should -BeExactly $Path
		}
	}
}

Describe 'Set-Location throws ItemNotFoundException' {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
		Push-Location -StackName BeforeEach
	}

	AfterEach {
		Pop-Location -StackName BeforeEach
	}

	It '<Path>' -TestCases $testCases_NotFound {
		{
			Set-Location -Path $Path -ErrorAction Stop
		} | Should -ExceptionType ([ItemNotFoundException])
	}
}
