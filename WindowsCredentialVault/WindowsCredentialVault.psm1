#Requires -Version 3.0

function InitializeWindowsCredential
{
    Write-Verbose ("Loading PasswordVault Class.")
    [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
}

InitializeWindowsCredential

# Private Module to load default configuration
function Get-CurrentConfigurationOrDefault
{

    [CmdletBinding()]
    param
    (
    )
    
    $ErrorActionPreference = 'Stop'

    try
    {
        if ($WindowsCredentialVault.context.count -gt 0) 
        {
            return $WindowsCredentialVault.context.peek().config
        } 
        else 
        {
            return $WindowsCredentialVault.config_default
        }
    }
    catch
    {
        throw $_
    }
}

function Import-WindowsCredentialVaultConfiguration
{

    [CmdletBinding()]
    param
    (
        [string]$OriginalConfigFilePath = (Join-Path $WindowsCredentialVault.originalconfig.root $WindowsCredentialVault.originalconfig.file),
        [string]$NewConfigFilePath = (Join-Path $WindowsCredentialVault.appdataconfig.root $WindowsCredentialVault.appdataconfig.file)
    )

    if (Test-Path $OriginalConfigFilePath -pathType Leaf)
    {
        try 
        {        
            Write-Verbose 'Load Current Configuration or Default.'
            $config = Get-CurrentConfigurationOrDefault
            . $OriginalConfigFilePath
            return
        } 
        catch 
        {
            throw ('Error Loading Configuration from {0}: ' -f $OriginalConfigFilePath) + $_
        }
    }

    if (Test-Path $NewConfigFilePath -pathType Leaf) 
    {
        try 
        {        
            Write-Verbose 'Load Current Configuration or Default.'
            $config = Get-CurrentConfigurationOrDefault
            . $NewConfigFilePath
            return
        } 
        catch 
        {
            throw ('Error Loading Configuration from {0}: ' -f $NewConfigFilePath) + $_
        }
    }
}

# contains default base configuration, may not be override without version update.
$Script:WindowsCredentialVault = [ordered]@{}
$WindowsCredentialVault.name = 'WindowsCredentialVault'
$WindowsCredentialVault.modulePath = Split-Path -parent $MyInvocation.MyCommand.Definition
$WindowsCredentialVault.helpersPath = "\functions"
$WindowsCredentialVault.combineTempfunction = '{0}.ps1' -f $WindowsCredentialVault.name
$WindowsCredentialVault.fileEncode  = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]'utf8'
$WindowsCredentialVault.context = New-Object System.Collections.Stack # holds onto the current state of all variables

# contains default configuration path
$WindowsCredentialVault.originalconfig = [ordered]@{
    root     = Join-Path $WindowsCredentialVault.modulePath '\config'
    file     = '{0}-config.ps1' -f $WindowsCredentialVault.name         # default configuration file name to read
}

$WindowsCredentialVault.appdataconfig = [ordered]@{
    root     = Join-Path $env:APPDATA $WindowsCredentialVault.name      # default configuration path
    file     = '{0}-config.ps1' -f $WindowsCredentialVault.name         # default configuration file name to read
}
$WindowsCredentialVault.appdataconfig.backup = Join-Path $WindowsCredentialVault.appdataconfig.root '\config'

# contains PS Build-in Preference status
$WindowsCredentialVault.preference = @{
    ErrorActionPreference = @{
        original = $ErrorActionPreference
        custom   = 'Stop'
    }
    DebugPreference       = @{
        original = $DebugPreference
        custom   = 'SilentlyContinue'
    }
    VerbosePreference     = @{
        original = $VerbosePreference
        custom   = 'SilentlyContinue'
    }
    ProgressPreference = @{
        original = $ProgressPreference
        custom   = 'SilentlyContinue'
    }
}

#-- Loading Internal Function when loaded --#

$ErrorActionPreference = $WindowsCredentialVault.preference.ErrorActionPreference.custom

$outputPath = Join-Path $WindowsCredentialVault.modulePath $WindowsCredentialVault.combineTempfunction
if (Test-Path $outputPath){ . $outputPath }

# -- Import Default configuration file -- #
Import-WindowsCredentialVaultConfiguration

#-- Export Modules when loading this module --#
# You can check with following Command
# Import-Module WindowsCredentialVault -Verbose -Force; $WindowsCredentialVault

Export-ModuleMember `
    -Function `
        * `
    -Variable `
        * `
    -Alias *