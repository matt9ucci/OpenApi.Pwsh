BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$TestDocRoot = "$PSScriptRoot\..\..\..\data\OpenApiDocument"
}

Describe 'Get-OpenApiParameter' {
	BeforeAll {
		$DocData = @{
			Doc1 = [OpenApiDocument]@{ Paths = @{} }
		}

		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) Root -OpenApiRegistry ([OpenApiBasicRegistry]::new($DocData))
	}

	AfterAll {
		Remove-PSDrive OpenApi -PSProvider ([OpenApiProvider]::ProviderName)
	}

	BeforeEach {
		Import-OpenApiDocument -Path (Join-Path $TestDocRoot OpenApi3_0 minimal.json) -OpenApiName Doc
		$doc = Get-OpenApiDocument -OpenApiName Doc
		$paths = $doc.Paths
		$paths['/users/{id}'] = @{}
		$paths['/users/{id}'].Operations['Get'] = @{ OperationId = 'GetUser' }

		$paths['/users/{id}'].Parameters.AddRange([OpenApiParameter[]]$PathItemParams)
		$paths['/users/{id}'].Operations['Get'].Parameters.AddRange([OpenApiParameter[]]$OperationParams)
	}

	It 'gets <PathItemParams.Count> from PathItem and <OperationParams.Count> from Operation' -TestCases @(
		@{
			PathItemParams = @()
			OperationParams = @()
		}
		@{
			PathItemParams = @()
			OperationParams = @(
				@{ In = 'Query'; Name = 'Operation_Query_01' }
			)
		}
		@{
			PathItemParams = @()
			OperationParams = @(
				@{ In = 'Query'; Name = 'Operation_Query_01' }
				@{ In = 'Query'; Name = 'Operation_Query_02' }
			)
		}
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_Path_01' }
			)
			OperationParams = @()
		}
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_Path_01' }
			)
			OperationParams = @(
				@{ In = 'Query'; Name = 'Operation_Query_01' }
			)
		}
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_Path_01' }
			)
			OperationParams = @(
				@{ In = 'Query'; Name = 'Operation_Query_01' }
				@{ In = 'Query'; Name = 'Operation_Query_02' }
			)
		}
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_Path_01' }
				@{ In = 'Path'; Name = 'PathItem_Path_02' }
			)
			OperationParams = @()
		}
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_Path_01' }
				@{ In = 'Path'; Name = 'PathItem_Path_02' }
			)
			OperationParams = @(
				@{ In = 'Query'; Name = 'Operation_Query_01' }
			)
		}
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_Path_01' }
				@{ In = 'Path'; Name = 'PathItem_Path_02' }
			)
			OperationParams = @(
				@{ In = 'Query'; Name = 'Operation_Query_01' }
				@{ In = 'Query'; Name = 'Operation_Query_02' }
			)
		}
	) {
		$result = Get-OpenApiParameter -OpenApiName Doc -OperationId GetUser

		$allParams = $PathItemParams + $OperationParams

		$result | Should -HaveCount $allParams.Count
		for ($i = 0; $i -lt $allParams.Count; $i++) {
			$result[$i].Name | Should -BeExactly $allParams[$i].Name
			$result[$i].In | Should -BeExactly $allParams[$i].In
		}
	}

	It 'gets unique OpenApiParameter' -TestCases @(
		@{
			PathItemParams = @(
				@{ In = 'Path'; Name = 'PathItem_unique_Path_01' }
				@{ In = 'Path'; Name = 'duplicate_Path_01'; Description = 'overridden' }
			)
			OperationParams = @(
				@{ In = 'Path'; Name = 'Operation_unique_Path_01' }
				@{ In = 'Path'; Name = 'duplicate_Path_01'; Description = 'override' }
			)
		}
		@{
			PathItemParams = @(
				@{ In = 'Query'; Name = 'PathItem_unique_Query_01' }
				@{ In = 'Query'; Name = 'duplicate_Query_01'; Description = 'overridden' }
				@{ In = 'Query'; Name = 'PathItem_unique_Query_02' }
				@{ In = 'Query'; Name = 'duplicate_Query_02'; Description = 'overridden' }
			)
			OperationParams = @(
				@{ In = 'Query'; Name = 'duplicate_Query_01'; Description = 'override' }
				@{ In = 'Query'; Name = 'Operation_unique_Query_01' }
				@{ In = 'Query'; Name = 'duplicate_Query_02'; Description = 'override' }
				@{ In = 'Query'; Name = 'Operation_unique_Query_02' }
			)
		}
	) {
		$result = Get-OpenApiParameter -OpenApiName Doc -OperationId GetUser

		$uniqueParams = $PathItemParams + $OperationParams | ? Description -ne 'overridden'

		$result | Should -HaveCount $uniqueParams.Count
		for ($i = 0; $i -lt $uniqueParams.Count; $i++) {
			$result[$i].Name | Should -BeExactly $uniqueParams[$i].Name
			$result[$i].In | Should -BeExactly $uniqueParams[$i].In
		}
	}
}
