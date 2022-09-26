using namespace System.Diagnostics.CodeAnalysis

BeforeDiscovery {
	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$TestDocRoot = "$PSScriptRoot\..\..\..\data\OpenApiDocument"
}

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe 'Convert-OpenApiDocument: <ModelTypeName>' -ForEach @(
	@{
		ModelTypeName = 'OpenApiDocument'
		ModelProperty = @{
			Info = @{
				Title   = 'Info Title'
				Version = '0.1.0'
			}
		}
		StringTable   = @{
			OpenApi2_0 = @{
				Json = Get-Content $TestDocRoot\OpenApi2_0\minimal.json
				Yaml = Get-Content $TestDocRoot\OpenApi2_0\minimal.yaml
			}
			OpenApi3_0 = @{
				Json = Get-Content $TestDocRoot\OpenApi3_0\minimal.json
				Yaml = Get-Content $TestDocRoot\OpenApi3_0\minimal.yaml
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
		@{ ConvertOpenApiDocument = { Convert-OpenApiDocument ($StringTable[$Version][$Format] | Out-String) } }
		@{ ConvertOpenApiDocument = { $StringTable[$Version][$Format] | Convert-OpenApiDocument } }
		@{ ConvertOpenApiDocument = { $StringTable[$Version][$Format] | Out-String | Convert-OpenApiDocument } }
	) {
		It '<Version> <Format>' -TestCases @(
			@{ Version = 'OpenApi2_0'; Format = 'Json' }
			@{ Version = 'OpenApi2_0'; Format = 'Yaml' }
			@{ Version = 'OpenApi3_0'; Format = 'Json' }
			@{ Version = 'OpenApi3_0'; Format = 'Yaml' }
		) {
			$actual = & $ConvertOpenApiDocument
			$actual.Info.Title | Should -BeExactly $Model.Info.Title
			$actual.Info.Version | Should -BeExactly $Model.Info.Version
		}
	}
}
