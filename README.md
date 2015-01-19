WindowsCredentialVault
============

What this for?
----

This module allows you to handle your credential with Windows Credential Manager.

It used to be requires P/Invoke to handle Windows Credential Manager. > [PInvoke.Net](http://www.pinvoke.net/default.aspx/credui.creduipromptforcredentials)

However there are [PasswordVault](http://msdn.microsoft.com/en-us/library/windows/apps/windows.security.credentials.passwordvault) class for Windows 8 StoreApops in .NET framework and it allows not only StoreApps but also PowerShell to manage their Credential super easy.
 
Usage
----

**Set Credential**

Below sample code will save your Credential as hoge.

```powershell
Set-WindowsCredential -ResourceName hoge -Credential (Get-Credential)
```

![](bin/SetPrompt.png)
![](bin/SetCredential.png)

**Get Credential**

```powershell
Get-WindowsCredential -ResourceName hoge
```

This retrieve all user credential for ResourceName 'hoge'.

```
UserName                                                                             Password
--------                                                                             --------
hoge                                                             System.Security.SecureString
```

You can specify username for the Resource.

```powershell
Get-WindowsCredential -ResourceName hoge -UserName hoge
```

Want to retrieve all credentials? Use ```-All``` switch.

```powershell
Get-WindowsCredential -All
```

**Test Credential is exist**

You can test if credential is exist or not.

```powershell
Test-WindowsCredential -ResourceName hoge
```

If credential is exist then ```true``` will be return. If not ```false``` will return.

You can specify Resource and UserName.

```powershell
Test-WindowsCredential -ResourceName hoge -UserName hoge
```

**Remove Credential**

You can remove credential.

```powershell
Remove-WindowsCredential -ResourceName hoge -UserName hoge
```

If you want to remove all credential in ResourceName, then use ```-All``` switch.

```powershell
Remove-WindowsCredential -ResourceName hoge -All
```

Tips
----

As PasswordVault use ```Windows.Security.Credentials.PasswordCredential```, this module convert to/from ```PSCredential```.

**ComvertTo-PasswordCredential**

Convert PSCredential TO Windows.Security.Credentials.PasswordCredential.

```powershell
ConvertTo-PasswordCredential -Credential (Get-Credential) -ResourceName hoge
```

**ComvertFrom-PasswordCredential**

Convert Windows.Security.Credentials.PasswordCredential to PSCredential.

```powershell
ConvertFrom-PasswordCredential -Credential $Credential
```