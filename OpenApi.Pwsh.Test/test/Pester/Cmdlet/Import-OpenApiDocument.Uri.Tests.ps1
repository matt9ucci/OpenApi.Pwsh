using namespace System.Diagnostics.CodeAnalysis

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe 'Import-OpenApiDocument -Uri' -Tag Web {
	BeforeAll {
		function Test-SingleUri {
			param (
				[Parameter(Mandatory)]
				[scriptblock]
				$ImportOpenApiDocument
			)

			$return = & $ImportOpenApiDocument

			$return | Should -BeNullOrEmpty

			$item = Get-Item -Path "$([Configuration]::Current.DriveName):$OpenApiName"
			$item | Should -Not -BeNullOrEmpty
			$item.PSChildName | Should -BeExactly $OpenApiName
		}
	}

	BeforeEach {
		New-PSDrive ([Configuration]::Current.DriveName) ([OpenApiProvider]::ProviderName) ''

		$fileBaseName = 'minimal'
		$version = [Configuration]::Current.Version.ToString()
		$format = [Configuration]::Current.Format.ToString()

		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Uri = [uri]"https://raw.githubusercontent.com/matt9ucci/OpenApi.Pwsh/main/OpenApi.Pwsh.Test/data/OpenApiDocument/${version}/${fileBaseName}.$($format.ToLower())"
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$OpenApiName = $fileBaseName
	}

	AfterEach {
		Remove-PSDrive ([Configuration]::Current.DriveName) -PSProvider ([OpenApiProvider]::ProviderName)
	}

	It 'Uri is Mandatory' {
		$metadata = (Get-Command -Name Import-OpenApiDocument).Parameters.Values
		$mandatories = $metadata | ? { $_.Attributes.Mandatory }
		$mandatories.Name | Should -Contain Uri
	}

	It 'imports <Uri>' {
		Test-SingleUri { Import-OpenApiDocument -Uri $Uri }
	}

	It '-Uri ValueFromPipeline [uri]' {
		Test-SingleUri { $Uri | Import-OpenApiDocument }
	}

	It '-OpenApiName sets the custom name' {
		$OpenApiName = 'CustomName'
		Test-SingleUri { Import-OpenApiDocument -Uri $Uri -OpenApiName $OpenApiName }
	}

	It '-OpenApiName sets the custom name; -Uri ValueFromPipeline [uri]' {
		$OpenApiName = 'CustomName'
		Test-SingleUri { $Uri | Import-OpenApiDocument -OpenApiName $OpenApiName }
	}

	It '-PassThru returns the imported doc' {
		$return = Import-OpenApiDocument -Uri $Uri -PassThru

		$return | Should -Not -BeNullOrEmpty

		$item = Get-Item -Path "$([Configuration]::Current.DriveName):$OpenApiName"
		$item | Should -Not -BeNullOrEmpty
		$item | Should -Be $return
	}
}
