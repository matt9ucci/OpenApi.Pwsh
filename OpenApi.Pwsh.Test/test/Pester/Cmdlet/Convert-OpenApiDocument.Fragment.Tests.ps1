using namespace System.Diagnostics.CodeAnalysis

BeforeDiscovery {
	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$TestFragmentRoot = "$PSScriptRoot\..\..\..\data\OpenApiDocument\Fragment"
}

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe 'Convert-OpenApiDocument: <ModelTypeName>' -ForEach @(
	@{
		ModelTypeName = 'OpenApiExternalDocs'
		ModelProperty = @{
			Description = 'ExternalDocs Description'
			Url         = 'https://example.com/ExternalDocs/Url'
		}
		StringTable   = @{
			OpenApi2_0 = @{
				Json = Get-Content $TestFragmentRoot\externaldocs.json
				Yaml = Get-Content $TestFragmentRoot\externaldocs.yaml
			}
			OpenApi3_0 = @{
				Json = Get-Content $TestFragmentRoot\externaldocs.json
				Yaml = Get-Content $TestFragmentRoot\externaldocs.yaml
			}
		}
	}
) {
	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Model = New-Object -TypeName $ModelTypeName -Property $ModelProperty
	}

	Describe '<ConvertOpenApiDocument>' -ForEach @(
		@{ ConvertOpenApiDocument = { Convert-OpenApiDocument $Model } }
		@{ ConvertOpenApiDocument = { $Model | Convert-OpenApiDocument } }
	) {
		It 'default version and format' {
			$actual = & $ConvertOpenApiDocument
			$expected = $StringTable["$([Configuration]::Current.Version)"]["$([Configuration]::Current.Format)"] -join "`n"
			$actual | Should -BeExactly $expected
		}
	}

	Describe '<ConvertOpenApiDocument>' -ForEach @(
		@{ ConvertOpenApiDocument = { Convert-OpenApiDocument ($StringArray | Out-String) -Type $Model.GetType() } }
		@{ ConvertOpenApiDocument = { $StringArray | Convert-OpenApiDocument -Type $Model.GetType() } }
		@{ ConvertOpenApiDocument = { $StringArray | Out-String | Convert-OpenApiDocument -Type $Model.GetType() } }
	) {
		BeforeEach {
			[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
			$StringArray = $StringTable["$([Configuration]::Current.Version)"]["$([Configuration]::Current.Format)"]
		}

		It 'default version and format' {
			$actual = & $ConvertOpenApiDocument
			Compare-Object $actual $Model -Property @(
				'Description'
				'Url'
			) | Should -BeNullOrEmpty
		}
	}

	Describe '<ConvertOpenApiDocument>' -ForEach @(
		@{ ConvertOpenApiDocument = { Convert-OpenApiDocument -Model $Model -Version $Version -Format $Format } }
	) {
		It '<Version> <Format>' -TestCases @(
			@{ Version = 'OpenApi2_0'; Format = 'Json' }
			@{ Version = 'OpenApi2_0'; Format = 'Yaml' }
			@{ Version = 'OpenApi3_0'; Format = 'Json' }
			@{ Version = 'OpenApi3_0'; Format = 'Yaml' }
		) {
			$actual = & $ConvertOpenApiDocument
			$actual | Should -BeExactly ($StringTable[$Version][$Format] -join "`n")
		}
	}

	Describe '<ConvertOpenApiDocument>' -ForEach @(
		@{ ConvertOpenApiDocument = { Convert-OpenApiDocument ($StringArray | Out-String) -Version $Version -Type $Model.GetType() } }
		@{ ConvertOpenApiDocument = { $StringArray | Convert-OpenApiDocument -Version $Version -Type $Model.GetType() } }
		@{ ConvertOpenApiDocument = { $StringArray | Out-String | Convert-OpenApiDocument -Version $Version -Type $Model.GetType() } }
	) {
		BeforeEach {
			[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
			$StringArray = $StringTable[$Version][$Format]
		}

		It '<Version> <Format>' -TestCases @(
			@{ Version = 'OpenApi2_0'; Format = 'Json' }
			@{ Version = 'OpenApi2_0'; Format = 'Yaml' }
			@{ Version = 'OpenApi3_0'; Format = 'Json' }
			@{ Version = 'OpenApi3_0'; Format = 'Yaml' }
		) {
			$actual = & $ConvertOpenApiDocument
			Compare-Object $actual $Model -Property @(
				'Description'
				'Url'
			) | Should -BeNullOrEmpty
		}
	}
}
