param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	function Test-GetContent {
		param (
			[Parameter(Mandatory)]
			[AllowNull()]
			$Expected
		)

		$actual = & $GetContent
		$actual | Write-Debug

		if ($Expected -is [IOpenApiSerializable]) {
			$serializedExpected = Get-Serialized -Serializable $Expected
			$actual -join "`n" | Should -Be $serializedExpected
		} else {
			$actual | Should -BeExactly $Expected
		}
	}

	function Get-Serialized {
		param (
			[Parameter(Mandatory)]
			[IOpenApiSerializable]
			$Serializable
		)

		$script:Version ??= [Configuration]::Current.Version
		$script:Format ??= [Configuration]::Current.Format
		$script:WriterSettings ??= [Configuration]::Current.OpenApiWriterSettings

		$stream = [MemoryStream]::new()
		[OpenApiSerializableExtensions]::Serialize($Serializable, $stream, $Version, $Format, $WriterSettings)

		$reader = [StreamReader]::new($stream);
		$reader.BaseStream.Position = 0;

		return $reader.ReadToEnd()
	}

	$Root = 'Root'

	$DocData = @{
		Doc1 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
		Doc2 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
	}

	$Registry = [OpenApiBasicRegistry]::new($DocData)

	New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) $Root -OpenApiRegistry $Registry
}

Describe '<GetContent>' -ForEach @(
	@{ GetContent = { Get-Content -Path $Path } }
	@{ GetContent = { Get-Content -LiteralPath $Path } }
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1') }
	) {
		Test-GetContent -Expected $DocData[$Segments[1]]
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'ExternalDocs') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info') }
	) {
		Test-GetContent -Expected $DocData[$Segments[1]].($Segments[2])
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'Contact') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Info', 'License') }
	) {
		Test-GetContent -Expected $DocData[$Segments[1]].($Segments[2]).($Segments[3])
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '0') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers', '1') }
	) {
		if ($Version -eq [OpenApiSpecVersion]::OpenApi2_0) {
			# OAS 2.0 does not support Server object
			Test-GetContent -Expected $null
		} else {
			Test-GetContent -Expected $DocData[$Segments[1]].($Segments[2])[$Segments[3]]
		}
	}
}

Describe 'Get-Content -Path wildcard' {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It '<Path>' -TestCases @(
		@{ Segments = @('OpenApi:', 'D*') }
		@{ Segments = @('OpenApi:', 'Doc?') }
		@{ Segments = @('OpenApi:', '*[12]') }
		@{ Segments = @('OpenApi:', '*[12]', 'ExternalDocs') }
		@{ Segments = @('OpenApi:', '*[12]', 'Info') }
		@{ Segments = @('OpenApi:', '*[12]', 'Info', 'Contact') }
		@{ Segments = @('OpenApi:', '*[12]', 'Info', 'License') }
		@{ Segments = @('OpenApi:', '*[12]', 'Servers', '0') }
		@{ Segments = @('OpenApi:', '*[12]', 'Servers', '1') }
	) {
		$actual = & Get-Content -Path $Path
		$actual | Write-Debug

		$serializedExpected = @()
		foreach ($expected in (Get-Item -Path $Path)) {
			$serializedExpected += Get-Serialized -Serializable $expected
		}

		$actual | Should -Be ($serializedExpected -split "`n")
	}
}

Describe 'Get-Content -TotalCount' {
	BeforeEach {
		$Segments = @('OpenApi:', 'Doc1')
		$Path = $Segments -join $ItemSeparator

		$actual = Get-Content -Path $Path -TotalCount $TotalCount
		$actual | Write-Debug
	}

	It '<TotalCount> gets all the content' -TestCases @(
		@{ TotalCount = [long]::MinValue }
		@{ TotalCount = -1 }
	) {
		$serializedExpected = Get-Serialized -Serializable $DocData[$Segments[1]]
		$actual | Should -Be ($serializedExpected -split '\n')
	}

	It '<TotalCount> gets <TotalCount> line' -TestCases @(
		@{ TotalCount = 0 }
	) {
		$actual | Should -BeNullOrEmpty
	}

	It '<TotalCount> gets <TotalCount> line(s)' -TestCases @(
		@{ TotalCount = 1 }
		@{ TotalCount = 2 }
	) {
		$serializedExpected = Get-Serialized -Serializable $DocData[$Segments[1]]
		$actual | Should -Be ($serializedExpected -split '\n')[0..($TotalCount - 1)]
	}
}

Describe 'Get-Content dynamic params' {
	BeforeEach {
		$Segments = @('OpenApi:', 'Doc1')
		$Path = $Segments -join $ItemSeparator

		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$GetContent = { Get-Content -Path $Path -Version $Version -Format $Format -WriterSettings $WriterSettings }
	}

	It '-Version <Version> -Format <Format>' -TestCases @(
		@{ Version = 'OpenApi2_0'; Format = 'Json' }
		@{ Version = 'OpenApi2_0'; Format = 'Yaml' }
		@{ Version = 'OpenApi3_0'; Format = 'Json' }
		@{ Version = 'OpenApi3_0'; Format = 'Yaml' }
	) {
		Test-GetContent -Expected $DocData[$Segments[1]]
	}

	It '-WriterSettings InlineLocalReferences:<WriterSettings.InlineLocalReferences> InlineExternalReferences:<WriterSettings.InlineExternalReferences>' -TestCases @(
		@{ WriterSettings = @{ InlineLocalReferences = $true; InlineExternalReferences = $true } }
		@{ WriterSettings = @{ InlineLocalReferences = $true; InlineExternalReferences = $false } }
		@{ WriterSettings = @{ InlineLocalReferences = $false; InlineExternalReferences = $true } }
		@{ WriterSettings = @{ InlineLocalReferences = $false; InlineExternalReferences = $false } }
	) {
		Test-GetContent -Expected $DocData[$Segments[1]]
	}
}

Describe 'Get-Content exceptions' {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
	}

	It 'Not serializable <Path>' -TestCases @(
		@{ Segments = @('OpenApi:') }
		@{ Segments = @('OpenApi:', 'Doc1', 'Servers') }
	) {
		{
			Get-Content -Path $Path -ErrorAction Stop
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
			Get-Content -Path $Path -ErrorAction Stop
		} | Should -ExceptionType ([ItemNotFoundException])
	}
}

Describe 'Get-Content strange behaviors' {
	It 'accepts pipeline input as a FileSystem provider: Path ByPropertyName' {
		{
			[pscustomobject]@{ Path = 'OpenApi:' + $ItemSeparator + 'Doc1' } | Get-Content -ErrorAction Stop
		} | Should -ExceptionType ([PSNotSupportedException]) -ExpectedMessage 'Microsoft.PowerShell.Commands.FileSystemContentReaderDynamicParameters is not supported.'
	}
}
