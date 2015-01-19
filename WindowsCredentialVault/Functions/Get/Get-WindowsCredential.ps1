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