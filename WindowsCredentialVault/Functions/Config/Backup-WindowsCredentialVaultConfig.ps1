function Backup-WindowsCredentialVaultConfig
{
<#
.Synopsis
   Backup CurrentConfiguration with timestamp.
.DESCRIPTION
   Backup configuration in $WindowsCredentialVault.appdataconfig.root
.EXAMPLE
   Backup-WindowsCredentialVaultConfig
#>

    [OutputType([Void])]
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
        $private:datePrefix = ([System.DateTime]::Now).ToString($WindowsCredentialVault.logs.dateformat)
        $private:backupConfigName = $datePrefix + "_" + $WindowsCredentialVault.appdataconfig.file
        $private:backupConfigPath = Join-Path $WindowsCredentialVault.appdataconfig.root $backupConfigName

        Write-Verbose ("Backing up config file '{0}' => '{1}'." -f $configPath, $backupConfigPath)
        Get-Content -Path $configPath -Encoding $encoding -Raw | Out-File -FilePath $backupConfigPath -Encoding $encoding -Force 
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }
}
