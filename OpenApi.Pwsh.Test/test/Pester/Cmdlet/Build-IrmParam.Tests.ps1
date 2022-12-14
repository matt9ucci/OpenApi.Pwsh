using namespace System.Collections.Generic
using namespace Microsoft.OpenApi.Models

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe 'Build-IrmParam' {
	BeforeEach {
		$DocData = @{
			Doc1 = [OpenApiDocument]@{ Servers = [List[OpenApiServer]]@(@{ Url = 'https://a' }); Paths = @{} }
			Doc2 = [OpenApiDocument]@{ Servers = [List[OpenApiServer]]@(@{ Url = 'https://b' }); Paths = @{} }
		}

		$paths = $DocData['Doc1'].Paths
		$paths['/users/{id}'] = @{}
		$paths['/users/{id}'].Operations['Get'] = @{ OperationId = 'GetUser' }

		$paths['/users/{id}'].Operations['Get'].Parameters.AddRange(
			[OpenApiParameter[]]@(
				@{
					In = 'Path'
					Name = 'id'
					Schema = @{ Type = 'string' }
					Required = $true
				}
				@{
					In = 'Query'
					Name = 'timeout'
					Schema = @{ Type = 'integer' }
				}
			)
		)

		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))
	}

	AfterEach {
		Remove-PSDrive OpenApi -PSProvider ([OpenApiProvider]::ProviderName)
	}

	It 'builds by required parameter' {
		$result = Build-IrmParam -OpenApiName Doc1 -OperationId GetUser -id abcd

		$result | Should -BeOfType [hashtable]
		$result.Uri | Should -BeExactly ([uri]::new('https://a/users/abcd'))
		$result.Method | Should -BeExactly ([WebRequestMethod]::Get)
		$result | Should -BeExactly $IrmParam
	}

	It 'builds by required parameter and optional one' {
		$result = Build-IrmParam -OpenApiName Doc1 -OperationId GetUser -id abcd -timeout 60

		$result | Should -BeOfType [hashtable]
		$result.Uri | Should -BeExactly ([uri]::new('https://a/users/abcd?timeout=60'))
		$result.Method | Should -BeExactly ([WebRequestMethod]::Get)
		$result | Should -BeExactly $IrmParam
	}
}

Describe 'Build-IrmParam: Servers' {
	BeforeEach {
		$DocData = @{
			Doc1 = [OpenApiDocument]@{ Paths = @{} }
			Doc2 = [OpenApiDocument]@{ Paths = @{} }
		}

		$paths = $DocData['Doc1'].Paths
		$paths['/users'] = @{}
		$paths['/users'].Operations['Get'] = @{ OperationId = 'GetUser' }

		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))

		Set-Item -Path OpenApi:\Doc1\Servers -Value ([List[OpenApiServer]]$Servers)
	}

	AfterEach {
		Remove-PSDrive OpenApi -PSProvider ([OpenApiProvider]::ProviderName)
	}

	It 'uses the 1st server when Servers.Count = <Servers.Count>' -TestCases @(
		@{ Servers = @(@{ Url = 'https://a/0' }) }
		@{ Servers = @(@{ Url = 'https://a/0' }, @{ Url = 'https://a/1' }) }
	) {
		$result = Build-IrmParam -OpenApiName Doc1 -OperationId GetUser

		$result.Uri | Should -BeLikeExactly "$($Servers[0].Url)*"
	}

	It 'throws exception when Servers.Count = <Servers.Count>' -TestCases @(
		@{ Servers = @() }
	) {
		{
			Build-IrmParam -OpenApiName Doc1 -OperationId GetUser
		} | Should -ExceptionType ([System.InvalidOperationException]) -ErrorId 'InvalidOperation,OpenApi.Pwsh.Cmdlet.BuildIrmParamCmdlet'
	}
}
