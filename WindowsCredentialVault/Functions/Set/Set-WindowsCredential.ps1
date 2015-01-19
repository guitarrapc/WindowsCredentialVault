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