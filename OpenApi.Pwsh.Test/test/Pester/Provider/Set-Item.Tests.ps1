using namespace System.Diagnostics.CodeAnalysis

param (
	$ItemSeparator = [System.IO.Path]::DirectorySeparatorChar
)

BeforeAll {
	. $PSScriptRoot\..\UsingNamespace.ps1
	. $PSScriptRoot\..\Import-OpenApi.Pwsh.ps1
}

Describe '<SetItem>' -ForEach @(
	@{ SetItem = { Set-Item -Path $Path -Value $Value } }
	@{ SetItem = { Set-Item -LiteralPath $Path -Value $Value } }
	@{ SetItem = { @(, $Value) | Set-Item -Path $Path } }
	@{ SetItem = { @(, $Value) | Set-Item -LiteralPath $Path } }
) {
	BeforeDiscovery {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$TestCreate = @{
			Name = 'creates  <ValueType.PadRight(19, '' '')> at <Path>'
			Test = {
				if ($Before) { & $Before }
				Test-Create
			}
		}
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$TestReplace = @{
			Name = 'replaces <ValueType.PadRight(19, '' '')> at <Path>'
			Test = {
				if ($Before) { & $Before }
				Test-Replace
			}
		}
	}

	BeforeAll {
		New-PSDrive OpenApi ([OpenApiProvider]::ProviderName) 'Root'

		function Test-Create {
			Test-Path -Path $Path | Should -BeFalse

			& $SetItem

			$result = Get-Item -Path $Path
			if (($Value.GetType().Name -eq 'List`1') -and ($Value.Count -eq 0)) {
				$result | Should -HaveCount 0
			} else {
				$result | Should -Be $Value
			}
		}

		function Test-Replace {
			Test-Path -Path $Path | Should -BeTrue

			& $SetItem

			$result = Get-Item -Path $Path
			if (($Value.GetType().Name -eq 'List`1') -and ($Value.Count -eq 0)) {
				$result | Should -HaveCount 0
			} else {
				$result | Should -Be $Value
			}
		}
	}

	BeforeEach {
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Path = $Segments -join $ItemSeparator
		[SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$Value = New-Object -TypeName $ValueType
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc')
		ValueType = 'OpenApiDocument'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc')
		ValueType = 'OpenApiDocument'
		Before    = {
			$Value.Info = $null
			$Value.Servers = $null
		}
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'ExternalDocs')
		ValueType = 'OpenApiExternalDocs'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'ExternalDocs')
		ValueType = 'OpenApiExternalDocs'
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Info')
		ValueType = 'OpenApiInfo'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Info')
		ValueType = 'OpenApiInfo'
		Before    = {
			$Value.Contact = $null
			$Value.License = $null
		}
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Info', 'Contact')
		ValueType = 'OpenApiContact'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Info', 'Contact')
		ValueType = 'OpenApiContact'
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Info', 'License')
		ValueType = 'OpenApiLicense'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Info', 'License')
		ValueType = 'OpenApiLicense'
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Servers')
		ValueType = 'List[OpenApiServer]'
		Before = {
			$Value.Add([OpenApiServer]::new())
			$Value.Add([OpenApiServer]::new())
		}
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Servers')
		ValueType = 'List[OpenApiServer]'
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Servers', '0')
		ValueType = 'OpenApiServer'
	}

	It @TestCreate -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Servers', '1')
		ValueType = 'OpenApiServer'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Servers', '0')
		ValueType = 'OpenApiServer'
	}

	It @TestReplace -TestCases @{
		Segments  = @('OpenApi:', 'Doc', 'Servers', '1')
		ValueType = 'OpenApiServer'
	}
}
