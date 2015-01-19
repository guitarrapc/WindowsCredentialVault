@echo off

pushd %~dp0
PowerShell -Command "$currentPolicy = Get-ExecutionPolicy; if($currentPolicy -eq 'Restricted'){Set-Executionpolicy RemoteSigned}else{Write-Host ('Your current Execution Policy is ''{0}''. Not changed your policy.' -f $currentPolicy) -ForegroundColor cyan}"
PowerShell .\%~n0.ps1 -Verbose