BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe 'Get-OpenApiDocument' {
	Context 'current drive ''<DriveName>''' -ForEach @(
		@{ DriveName = 'OpenApi' }
		@{ DriveName = 'CustomOpenApiDrive' }
	) {
		BeforeAll {
			New-PSDrive $DriveName ([OpenApiProvider]::ProviderName) ''
			[Configuration]::Current.DriveName = $DriveName

			Set-Item -Path "${DriveName}:Cat01" -Value ([OpenApiDocument]@{ Info = @{ Title = 'Cat01' } })
			Set-Item -Path "${DriveName}:Cat02" -Value ([OpenApiDocument]@{ Info = @{ Title = 'Cat02' } })
			Set-Item -Path "${DriveName}:Dog01" -Value ([OpenApiDocument]@{ Info = @{ Title = 'Dog01' } })
			Set-Item -Path "${DriveName}:Dog02" -Value ([OpenApiDocument]@{ Info = @{ Title = 'Dog02' } })
		}

		AfterAll {
			Remove-PSDrive $DriveName -PSProvider $ProviderName
			[Configuration]::Current = [Configuration]::new()
		}

		It 'gets all docs if OpenApiName is not specified' {
			$item = Get-OpenApiDocument

			$item | Should -HaveCount 4
		}

		It 'gets one doc by OpenApiName ''<OpenApiName>''' -TestCases @(
			@{ OpenApiName = 'Cat02' }
		) {
			$item = Get-OpenApiDocument -OpenApiName $OpenApiName

			$item | Should -HaveCount 1
			$item.Info.Title | Should -BeExactly Cat02
		}

		It 'gets two docs by OpenApiName ''<OpenApiName>''' -TestCases @(
			@{ OpenApiName = 'Cat0?' }
			@{ OpenApiName = 'Cat0[12]' }
			@{ OpenApiName = 'Cat*' }
		) {
			$item = Get-OpenApiDocument -OpenApiName $OpenApiName | Sort-Object PSChildName

			$item | Should -HaveCount 2
			$item[0].Info.Title | Should -BeExactly Cat01
			$item[1].Info.Title | Should -BeExactly Cat02
		}

		It 'throws ItemNotFoundException by OpenApiName ''<OpenApiName>''' -TestCases @(
			@{ OpenApiName = 'NotExist' }
		) {
			{
				Get-OpenApiDocument -OpenApiName $OpenApiName -ErrorAction Stop
			} | Should -ExceptionType ([ItemNotFoundException]) -ErrorId 'SessionStateException,OpenApi.Pwsh.Cmdlet.GetOpenApiDocumentCmdlet'
		}
	}
}
