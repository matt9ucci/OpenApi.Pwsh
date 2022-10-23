BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	$DocData = @{
		Doc1 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
		Doc2 = & $PSScriptRoot\..\New-OpenApiDocument.ps1
	}

	New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))
}

Describe 'Show-OpenApiExternalDocs -AsModel' {
	It '<Cmdlet>' -TestCases @(
		@{ Cmdlet = { Show-OpenApiExternalDocs Doc1 -AsModel } }
		@{ Cmdlet = { Show-OpenApiExternalDocs -OpenApiName Doc1 -AsModel } }
	) {
		$result = & $Cmdlet

		$result | Should -BeOfType ([OpenApiExternalDocs])
		$result.Url.ToString() | Should -BeExactly 'https://example.com/ExternalDocs/Url'
	}

	It '<Cmdlet>' -TestCases @(
		@{ Cmdlet = { Show-OpenApiExternalDocs Doc1 path01 -AsModel } }
		@{ Cmdlet = { Show-OpenApiExternalDocs -OpenApiName Doc1 -OperationId path01 -AsModel } }
	) {
		$result = & $Cmdlet

		$result | Should -BeOfType ([OpenApiExternalDocs])
		$result.Url.ToString() | Should -BeExactly 'https://example.com/Get/path01/ExternalDocs/Url'
	}

	It 'throws ItemNotFoundException by OpenApiName' {
		{
			Show-OpenApiExternalDocs -OpenApiName NotFound -AsModel
		} | Should -ExceptionType ([ItemNotFoundException]) -ErrorId 'SessionStateException,OpenApi.Pwsh.Cmdlet.ShowOpenApiExternalDocsCmdlet'
	}

	It 'throws ItemNotFoundException by OperationId' {
		{
			Show-OpenApiExternalDocs -OpenApiName Doc1 -OperationId NotFound -AsModel
		} | Should -ExceptionType ([ItemNotFoundException]) -ErrorId 'SessionStateException,OpenApi.Pwsh.Cmdlet.ShowOpenApiExternalDocsCmdlet'
	}
}
