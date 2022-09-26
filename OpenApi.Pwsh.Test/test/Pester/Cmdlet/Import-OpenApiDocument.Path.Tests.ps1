using namespace System.Diagnostics.CodeAnalysis

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1

	[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	$TestDocRoot = "$PSScriptRoot\..\..\..\data\OpenApiDocument"
}

Describe 'Import-OpenApiDocument -Path' {
	BeforeAll {
		function Test-SinglePath {
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
		$Path = Join-Path $TestDocRoot $version "$fileBaseName.$($format.ToLower())"
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$OpenApiName = $fileBaseName
	}

	AfterEach {
		Remove-PSDrive ([Configuration]::Current.DriveName) -PSProvider ([OpenApiProvider]::ProviderName)
	}

	It 'Path is Mandatory' {
		$metadata = (Get-Command -Name Import-OpenApiDocument).Parameters.Values
		$mandatories = $metadata | ? { $_.Attributes.Mandatory }
		$mandatories.Name | Should -Contain Path
	}

	It 'imports <Path>' {
		Test-SinglePath { Import-OpenApiDocument -Path $Path }
	}

	It '-Path ValueFromPipeline [string]' {
		Test-SinglePath { $Path | Import-OpenApiDocument }
	}

	It '-Path ValueFromPipeline [System.IO.FileInfo]' {
		Test-SinglePath { Get-Item -Path $Path | Import-OpenApiDocument }
	}

	It '-OpenApiName sets the custom name' {
		$OpenApiName = 'CustomName'
		Test-SinglePath { Import-OpenApiDocument -Path $Path -OpenApiName $OpenApiName }
	}

	It '-OpenApiName sets the custom name; -Path ValueFromPipeline [string]' {
		$OpenApiName = 'CustomName'
		Test-SinglePath { $Path | Import-OpenApiDocument -OpenApiName $OpenApiName }
	}

	It '-OpenApiName sets the custom name; -Path ValueFromPipeline [System.IO.FileInfo]' {
		$OpenApiName = 'CustomName'
		Test-SinglePath { Get-Item -Path $Path | Import-OpenApiDocument -OpenApiName $OpenApiName }
	}

	It '-PassThru returns the imported doc' {
		$return = Import-OpenApiDocument -Path $Path -PassThru

		$return | Should -Not -BeNullOrEmpty

		$item = Get-Item -Path "$([Configuration]::Current.DriveName):$OpenApiName"
		$item | Should -Not -BeNullOrEmpty
		$item | Should -Be $return
	}
}

Describe 'Import-OpenApiDocument -Path @()' {
	BeforeAll {
		$fileBaseName = 'minimal'

		$Path = @()
		$OpenApiNames = @()
		foreach ($version in @('OpenApi2_0', 'OpenApi3_0')) {
			foreach ($format in @('json', 'yaml')) {
				$inputPath = Join-Path $TestDocRoot $version "${fileBaseName}.${format}"
				$openApiName = "${fileBaseName}_${version}_${format}"
				$outputPath = Join-Path TestDrive: "${openApiName}.${format}"

				Get-Content -Path $inputPath | Set-Content -Path $outputPath

				$Path += $outputPath
				$OpenApiNames += $openApiName
			}
		}

		function Test-MultiplePath {
			param (
				[Parameter(Mandatory)]
				[scriptblock]
				$ImportOpenApiDocument
			)

			$return = & $ImportOpenApiDocument

			$return | Should -BeNullOrEmpty

			foreach ($name in $OpenApiNames) {
				$item = Get-Item -Path "$([Configuration]::Current.DriveName):${name}"
				$item | Should -Not -BeNullOrEmpty
				$item.PSChildName | Should -BeExactly $name
			}
		}
	}

	BeforeEach {
		New-PSDrive ([Configuration]::Current.DriveName) ([OpenApiProvider]::ProviderName) ''
	}

	AfterEach {
		Remove-PSDrive ([Configuration]::Current.DriveName) -PSProvider ([OpenApiProvider]::ProviderName)
	}

	It 'imports <Path>' {
		Test-MultiplePath { Import-OpenApiDocument -Path $Path }
	}

	It '-Path ValueFromPipeline [string]' {
		Test-MultiplePath { $Path | Import-OpenApiDocument }
	}

	It '-Path ValueFromPipeline [System.IO.FileInfo]' {
		Test-MultiplePath { Get-Item -Path $Path | Import-OpenApiDocument }
	}

	It '-PassThru returns the imported docs' {
		$return = Import-OpenApiDocument -Path $Path -PassThru

		$return | Should -HaveCount 4

		foreach ($r in $return) {
			$item = Get-Item -Path "$([Configuration]::Current.DriveName):$($r.PSChildName)"
			$item | Should -Not -BeNullOrEmpty
			$item | Should -Be $r
		}
	}

	It '-OpenApiName throws exception' {
		{
			Import-OpenApiDocument -Path $Path -OpenApiName 'CanNotSet'
		} | Should -ExceptionType ([System.Management.Automation.PSArgumentException]) -ErrorId 'Argument,OpenApi.Pwsh.Cmdlet.ImportOpenApiDocument'
	}
}
