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