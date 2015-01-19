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

    [OutputType([PSCredential[]])]
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
