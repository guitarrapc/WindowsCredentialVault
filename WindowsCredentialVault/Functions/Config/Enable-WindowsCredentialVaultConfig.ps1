function Enable-WindowsCredentialVaultConfig
{
<#
.Synopsis
   Enable specific WindowsCredentialVault Config
.DESCRIPTION
   Read config and replace with current
.EXAMPLE
   Show-WindowsCredentialVaultConfig
#>
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(mandatory = 0, position = 0)]
        [WindowsCredentialVaultProjectType]$project,

        [parameter(mandatory = 0, position = 1)]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding = $WindowsCredentialVault.fileEncode
    )

    $private:configBackupPath = $WindowsCredentialVault.appdataconfig.Backup
    $private:configPath = Join-Path $WindowsCredentialVault.appdataconfig.root $WindowsCredentialVault.appdataconfig.file

    if (!(Test-Path $configBackupPath)){ throw New-Object System.IO.FileNotFoundException "Unable to find the specified config backup path.", $configPath }

    Get-ChildItem -Path $configBackupPath -File -Recurse  `
    | Where-Object name -like "*$project*" `
    | ForEach-Object{
        Write-Verbose ("Read desired config file : {0}, Export to : {1}" -f $_.fullname, $configPath)
        Get-Content -Path $_.fullname -Raw | Out-File -FilePath $configPath -Encoding $encoding -Force

        Write-Verbose "Run Reset-WindowsCredentialVaultConfig to Reload Configuration to current session."
        Reset-WindowsCredentialVaultConfig
    }
}
