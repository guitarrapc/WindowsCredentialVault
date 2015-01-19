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

    [OutputType([Windows.Security.Credentials.PasswordCredential[]])]
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
