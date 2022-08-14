$moduleRoot = ${OpenApi.Pwsh.Test.Configuration}.ModuleRoot ?? "$PSScriptRoot\..\..\bin\Debug\net6.0"
Import-Module (Join-Path $moduleRoot OpenApi.Pwsh.psd1) -Force
