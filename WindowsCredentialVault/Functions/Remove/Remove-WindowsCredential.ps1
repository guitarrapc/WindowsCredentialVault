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