function Reset-WindowsCredentialVaultConfig
{
<#
.Synopsis
   Reload latest WindowsCredentialVault Config
.DESCRIPTION
   Import Config settings into current PowerShell session
.EXAMPLE
   Reset-WindowsCredentialVaultConfig
#>

    [CmdletBinding()]
    param
    (
        [parameter(mandatory = 0, position = 0)]
        [System.String]$configPath = (Join-Path $WindowsCredentialVault.appdataconfig.root $WindowsCredentialVault.appdataconfig.file),

        [parameter(mandatory = 0, position = 1)]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding = $WindowsCredentialVault.fileEncode
    )

    if (Test-Path $configPath)
    {
        . "$configPath"
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }
}