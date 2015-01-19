function Edit-WindowsCredentialVaultConfig
{
<#
.Synopsis
   Edit WindowsCredentialVault Config in Console
.DESCRIPTION
   Read config and edit in the console
.EXAMPLE
   Edit-WindowsCredentialVaultConfig
#>

    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(mandatory = 0, position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String]$configPath = (Join-Path $WindowsCredentialVault.appdataconfig.root $WindowsCredentialVault.appdataconfig.file),

        [parameter(mandatory = 0, position = 1)]
        [System.Management.Automation.SwitchParameter]$NoProfile
    )

    if (Test-Path $configPath)
    {
        if ($NoProfile)
        {
            powershell_ise.exe -File $configPath
        }
        else
        {
            powershell_ise.exe $configPath
        }
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'.")
    }

}
