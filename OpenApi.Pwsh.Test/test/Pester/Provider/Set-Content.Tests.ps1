using namespace System.Diagnostics.CodeAnalysis

param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeDiscovery {
	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$TestCreate = @{
		Name = 'creates  <ItemType.PadRight(15, '' '')> at <Path>'
		Test = {
			Test-Create
		}
	}
	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$TestReplace = @{
		Name = 'replaces <ItemType.PadRight(15, '' '')> at <Path>'
		Test = {
			Test-Replace
		}
	}

	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$MinimalDoc = @{
		OpenApi2_0 = @{
			Json = @(
				'{'
				'  "swagger": "2.0",'
				'  "info": {'
				'    "title": "Minimal Doc",'
				'    "version": "0.1.0"'
				'  },'
				'  "paths": { }'
				'}'
			)
			Yaml = @(
				'swagger: ''2.0'''
				'info:'
				'  title: Minimal Doc'
				'  version: 0.1.0'
				'paths: { }'
			)
		}
		OpenApi3_0 = @{
			Json = @(
				'{'
				'  "openapi": "3.0.1",'
				'  "info": {'
				'    "title": "Minimal Doc",'
				'    "version": "0.1.0"'
				'  },'
				'  "paths": { }'
				'}'
			)
			Yaml = @(
				'openapi: 3.0.1'
				'info:'
				'  title: Minimal Doc'
				'  version: 0.1.0'
				'paths: { }'
			)
		}
	}
}

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	function Test-Create {
		Test-Path -Path $Path | Should -BeFalse

		& $SetContent

		Test-Path -Path $Path | Should -BeTrue
		Get-Item -Path $Path | Should -BeOfType ([type]$ItemType)
	}

	function Test-Replace {
		$existingItem = Get-Item -Path $Path
		$existingItem | Should -Not -BeNullOrEmpty

		& $SetContent

		$result = Get-Item -Path $Path
		$result | Should -Not -Be $existingItem
		$result | Should -BeOfType ([type]$ItemType)
	}
}

Describe '<SetContent>' -ForEach @(
	@{ SetContent = { Set-Content -Path $Path -Value $Value } }
	@{ SetContent = { Set-Content -LiteralPath $Path -Value $Value } }
	@{ SetContent = { $Value | Out-String | Set-Content -Path $Path } }
	@{ SetContent = { $Value | Out-String | Set-Content -LiteralPath $Path } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Value = $ValueHashTable[$Version][$Format]
	}

	Context '<Version> <Format>' -ForEach @(
		@{ Version = 'OpenApi2_0'; Format = 'Json' }
		@{ Version = 'OpenApi2_0'; Format = 'Yaml' }
		@{ Version = 'OpenApi3_0'; Format = 'Json' }
		@{ Version = 'OpenApi3_0'; Format = 'Yaml' }
	) {
		BeforeAll {
			New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root
		}

		It @TestCreate -TestCases @{
			Segments       = @('OpenApi:', 'Doc')
			ItemType       = 'OpenApiDocument'
			ValueHashTable = $MinimalDoc
		}

		It @TestReplace -TestCases @{
			Segments       = @('OpenApi:', 'Doc')
			ItemType       = 'OpenApiDocument'
			ValueHashTable = $MinimalDoc
		}
	}
}

Describe 'Set-Content exceptions' {
	BeforeEach {
		$DocData = @{
			Doc1 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
			Doc2 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
		}
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))

		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Value = '{ "openapi": "3.0.1", "info": { "title": "Minimal Doc", "version": "0.1.0" }, "paths": { } }'
	}

	It 'Not supported <Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'ExternalDocs') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '1') }
	) {
		Test-Path -Path $Path | Should -BeTrue

		{
			Set-Content -Path $Path -Value $Value -ErrorAction Stop
		} | Should -ExceptionType ([PSInvalidCastException])

		# Set-Content always calls IContentCmdletProvider.ClearContent() regardless of exception
		Test-Path -Path $Path | Should -BeFalse
	}
}

Describe 'Set-Content strange behaviors' {
	BeforeEach {
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root
	}

	It 'accepts pipeline input as a FileSystem provider: Path ByPropertyName' {
		{
			[pscustomobject]@{ Path = 'OpenApi:' + $ItemSeparator + 'Doc1' } | Set-Content -Value 'dummy' -ErrorAction Stop
		} | Should -ExceptionType ([PSNotSupportedException]) -ExpectedMessage 'Microsoft.PowerShell.Commands.FileSystemContentWriterDynamicParameters is not supported.'
	}
}
