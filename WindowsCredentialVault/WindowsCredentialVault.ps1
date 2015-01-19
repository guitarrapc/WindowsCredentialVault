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

# file loaded from path : \functions\Config\Backup-WindowsCredentialVaultConfig.ps1

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

# file loaded from path : \functions\Config\Edit-WindowsCredentialVaultConfig.ps1

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

# file loaded from path : \functions\Config\Enable-WindowsCredentialVaultConfig.ps1

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
# file loaded from path : \functions\Config\Reset-WindowsCredentialVaultConfig.ps1

function Show-WindowsCredentialVaultConfig
{
<#
.Synopsis
   Read WindowsCredentialVault current config and show Config in Console
.DESCRIPTION
   Read config and show it on console.
.EXAMPLE
   Show-WindowsCredentialVaultConfig
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
        Get-Content -Path $configPath -Encoding $encoding
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }
}

# file loaded from path : \functions\Config\Show-WindowsCredentialVaultConfig.ps1

function ConvertFrom-PasswordCredential
{
<#
.Synopsis
   Convert WindowsCredential to PSCredential
.DESCRIPTION
   WindowsCredential class should use PasswordVault thus PSCredential converter is required.
   This function will convert PasswordCredential Class to PSCredential.
.EXAMPLE
   ConvertFrom-PasswordCredential -Credential $Credential
#>

    [OutputType([PSCredential])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [Windows.Security.Credentials.PasswordCredential[]]$Credential
    )

    process
    {
        foreach ($item in $Credential)
        {
            Write-Verbose ("Converting WindowsCredential to PSCredential")
            if ($item.UserName -eq [string]::Empty){ throw New-Object System.NullReferenceException }
            New-Object System.Management.Automation.PSCredential -ArgumentList ($item.UserName, (ConvertTo-SecureString $item.Password -AsPlainText -Force))
        }
    }
}

# file loaded from path : \functions\Converter\ConvertFrom-PasswordCredential.ps1

function ConvertTo-PasswordCredential
{
<#
.Synopsis
   Convert PSCredential to WindowsCredential
.DESCRIPTION
   WindowsCredential class should use PasswordVault thus PSCredential converter is required.
   This function will convert PSCredential to PasswordCredential Class.
.EXAMPLE
   ConvertTo-PasswordCredential -Credential (Get-Credential) -ResourceName hoge
#>

    [OutputType([Windows.Security.Credentials.PasswordCredential])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSCredential[]]$Credential,

        [parameter(Mandatory = 1, Position = 1)]
        [string]$ResourceName
    )

    process
    {
        foreach ($item in $Credential)
        {
            Write-Verbose ("Converting PSCredential to WindowsCredential")
            New-Object Windows.Security.Credentials.PasswordCredential -ArgumentList ($ResourceName, $item.UserName, $item.GetNetworkCredential().Password)
        }
    }
}

# file loaded from path : \functions\Converter\ConvertTo-PasswordCredential.ps1

function Get-WindowsCredential
{
<#
.Synopsis
   Get PSCredential from Windows Credential Vault
.DESCRIPTION
   Retrieve Credential from Windows Credential Vault and return as PSCredential
.EXAMPLE
   Get-WindowsCredential -ResourceName hoge
.EXAMPLE
   Get-WindowsCredential -ResourceName hoge -UserName username
.EXAMPLE
   Get-WindowsCredential -ResourceName hoge -UserName username, fuga
.EXAMPLE
   Get-WindowsCredential -All
#>
    [OutputType([PSCredential])]
    [CmdletBinding(DefaultParameterSetName = "Specific")]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ParameterSetName = "Specific")]
        [string]$ResourceName,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Specific")]
        [string[]]$UserName = [string]::Empty,

        [parameter(Mandatory = 0, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "All")]
        [switch]$All
    )
    
    process
    {
        try
        {
            if ($All)
            {
                (New-Object Windows.Security.Credentials.PasswordVault).RetrieveAll() | % { $_.RetrievePassword(); $_ } | ConvertFrom-PasswordCredential
                return;
            }

            foreach ($item in $UserName)
            {
                if ($item -ne [string]::Empty)
                {
                    Write-Verbose ("Retrieving WindowsCredential from ResourceName : '{0}', UserName : '{1}'" -f $ResourceName, $item)
                    (New-Object Windows.Security.Credentials.PasswordVault).Retrieve($ResourceName, $item) | % { $_.RetrievePassword(); $_ } | ConvertFrom-PasswordCredential
                }
                else
                {
                    Write-Verbose ("Retrieving All Windows Credential for ResourceName : '{0}'" -f $ResourceName)
                    (New-Object Windows.Security.Credentials.PasswordVault).FindAllByResource($ResourceName) | % { $_.RetrievePassword(); $_ } | ConvertFrom-PasswordCredential
                    return;
                }
            }
        }
        catch
        {
            throw $_
        }
    }
}
# file loaded from path : \functions\Get\Get-WindowsCredential.ps1

function Remove-WindowsCredential
{
<#
.Synopsis
   Remove Windows Credential Vault from specific ResourceName
.DESCRIPTION
   This function will remove your PSCredential from Password Vault.
.EXAMPLE
    Remove-WindowsCredential -ResourceName hoge -UserName username
.EXAMPLE
    Remove-WindowsCredential -ResourceName hoge -All
#>
    [OutputType([Void])]
    [CmdletBinding(DefaultParameterSetName = "Specific")]
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [string]$ResourceName,

        [parameter(Mandatory = 1, Position = 1, ParameterSetName = "Specific")]
        [string[]]$UserName = [string]::Empty,

        [parameter(Mandatory = 1, Position = 2, ParameterSetName = "All")]
        [switch]$All
    )

    begin
    {
        filter RemoveCredential
        {
            $_ | ConvertTo-PasswordCredential -ResourceName $ResourceName `
            | %{
                Write-Verbose ("Removing Windows Password Vault for ResourceName : '{0}', UserName : '{1}'" -f $ResourceName, $_.UserName)
                (New-Object Windows.Security.Credentials.PasswordVault).Remove($_)
            }
        }
    }
    process
    {
        try
        {
            if ($All)
            {
                Get-WindowsCredential -ResourceName $ResourceName | RemoveCredential
                return;
            }

            $UserName `
            | where {Test-WindowsCredential -UserName $_ -ResourceName $ResourceName} `
            | Get-WindowsCredential -ResourceName $ResourceName `
            | RemoveCredential
        }
        catch
        {
            throw $_
        }
    }
}
# file loaded from path : \functions\Remove\Remove-WindowsCredential.ps1

function Set-WindowsCredential
{
<#
.Synopsis
   Set to Windows Credential Vault with specific ResourceName
.DESCRIPTION
   This function will store your PSCredential to Password Vault.
.EXAMPLE
    Set-WindowsCredential -ResourceName hoge -Credential (Get-Credential)
.EXAMPLE
    Set-WindowsCredential -ResourceName hoge -Credential (Get-Credential), (Get-Credential)
#>
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [string]$ResourceName,

        [parameter(Mandatory = 1, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSCredential[]]$Credential
    )
    
    process
    {
        try
        {
            foreach ($item in $Credential)
            {
                Write-Verbose ("Set Windows Credential for UserName : '{0}'" -f $item.UserName)
                $winCred = $item | ConvertTo-PasswordCredential -ResourceName $ResourceName
                (New-Object Windows.Security.Credentials.PasswordVault).Add($winCred)
            }
        }
        catch
        {
            throw $_
        }
    }
}
# file loaded from path : \functions\Set\Set-WindowsCredential.ps1

function Test-WindowsCredential
{
<#
.Synopsis
   Test Windows Credential Vault is exist as desired parameter
.DESCRIPTION
   Test desired credential can be retrieve from Credential Vault.
.EXAMPLE
   Test-WindowsCredential -ResourceName hoge
.EXAMPLE
   Test-WindowsCredential -ResourceName hoge -UserName username
#>
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0)]
        [string]$ResourceName,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [string]$UserName = ([string]::Empty)
    )
    
    process
    {
        try
        {
            # Check Windows Credential Vault
            $result = if ($UserName -ne [string]::Empty)
            {
                Write-Verbose ("Testing get Windows Credential from ResourceName : '{0}', UserName : '{1}'" -f $ResourceName, $UserName)
                (New-Object Windows.Security.Credentials.PasswordVault).Retrieve($ResourceName, $UserName)
            }
            else
            {
                Write-Verbose ("Testing get All Windows Credential for ResourceName : '{0}'" -f $ResourceName)
                (New-Object Windows.Security.Credentials.PasswordVault).FindAllByResource($ResourceName)
            }
        
            # return result
            if (@($result).Count -ne 0){ return $true }
        }
        catch
        {
            return $false
        }
    }
}
# file loaded from path : \functions\Test\Test-WindowsCredential.ps1

