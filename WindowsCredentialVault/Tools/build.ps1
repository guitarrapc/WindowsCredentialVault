function CombineMultipleFileToSingle ([string]$InputRootPath, [string]$OutputPath, $Encoding)
{
    try
    {
        $sb = New-Object System.Text.StringBuilder
        $sw = New-Object System.IO.StreamWriter ($OutputPath, $false, [System.Text.Encoding]::$Encoding)

        # Read All functions
        Get-ChildItem $InputRootPath -Recurse -File `
        | Where-Object { -not ($_.FullName.Contains('.Tests.')) } `
        | Where-Object Extension -eq '.ps1' `
        | ForEach-Object {
            $sb.Append((Get-Content -Path $_.FullName -Raw -Encoding utf8)) > $null
            $sb.AppendLine() > $null
            $footer = '# file loaded from path : {0}' -f $_.FullName.Replace($WindowsCredentialVault.modulePath, "")
            $sb.Append($footer) > $null
            $sb.AppendLine() > $null
            $sb.AppendLine() > $null
        }
    
        # Output into single file
        $sw.Write($sb.ToString());
    }
    finally
    {
        # Dispose and release file handler
        $sb = $null
        $sw.Dispose()
    }
}

$Script:WindowsCredentialVault = [ordered]@{}
$WindowsCredentialVault.name = "WindowsCredentialVault"
$WindowsCredentialVault.Description = "PowerShell Windows Credential Vault Module"
$WindowsCredentialVault.CopyRight = "19/Jan/2015 -"
$WindowsCredentialVault.ExportPath = Split-Path $PSCommandPath -Parent
$WindowsCredentialVault.modulePath = Split-Path -parent $WindowsCredentialVault.ExportPath
$WindowsCredentialVault.helpersPath = '\functions\'
$WindowsCredentialVault.combineTempfunction = '{0}.ps1' -f $WindowsCredentialVault.name
$WindowsCredentialVault.fileEncode = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]'utf8'

$WindowsCredentialVault.RequiredModules = @()
$WindowsCredentialVault.clrVersion = "4.0.0.0"
$WindowsCredentialVault.variableToExport = "WindowsCredentialVault"

$WindowsCredentialVault.moduleVersion = "1.0.0"
$WindowsCredentialVault.functionToExport = @(
    # config
        'Backup-WindowsCredentialVaultConfig',
        'Edit-WindowsCredentialVaultConfig',
        'Enable-WindowsCredentialVaultConfig',
        'Reset-WindowsCredentialVaultConfig',
        'Show-ModuleConfig'
    # Converter
        'ConvertFrom-PasswordCredential',
        'ConvertTo-PasswordCredential',
    # Get
        'Get-WindowsCredential',
    # Remove
        'Remove-WindowsCredential',
    # Set
        'Set-WindowsCredential',
    # Test
        'Test-WindowsCredential'
)

$script:moduleManufest = @{
    Path = "{0}.psd1" -f $WindowsCredentialVault.name
    Author = "guitarrapc";
    CompanyName = "guitarrapc"
    Copyright = $WindowsCredentialVault.CopyRight;
    ModuleVersion = $WindowsCredentialVault.moduleVersion
    description = $WindowsCredentialVault.Description;
    PowerShellVersion = "3.0";
    DotNetFrameworkVersion = "4.0";
    ClrVersion = $WindowsCredentialVault.clrVersion;
    NestedModule = "{0}.psm1" -f $WindowsCredentialVault.name
    CmdletsToExport = "*";
    FunctionsToExport = $WindowsCredentialVault.functionToExport
    VariablesToExport = $WindowsCredentialVault.variableToExport;
}

New-ModuleManifest @moduleManufest

# As Installer place on ModuleName\Tools.
$psd1 = Join-Path $WindowsCredentialVault.ExportPath ("{0}.psd1" -f $WindowsCredentialVault.name);
$newpsd1 = Join-Path $WindowsCredentialVault.ModulePath ("{0}.psd1" -f $WindowsCredentialVault.name);
if (Test-Path -Path $psd1)
{
    Get-Content -Path $psd1 -Encoding UTF8 -Raw -Force | Out-File -FilePath $newpsd1 -Encoding default -Force
    Remove-Item -Path $psd1 -Force
}

# Combine all functions into single .ps1
$outputPath = Join-Path $WindowsCredentialVault.modulePath $WindowsCredentialVault.combineTempfunction
$InputRootPath = (Join-Path $WindowsCredentialVault.modulePath $WindowsCredentialVault.helpersPath)
if(Test-Path $outputPath){ Remove-Item -Path $outputPath -Force }
CombineMultipleFileToSingle -InputRootPath $InputRootPath -OutputPath $outputPath -Encoding UTF8