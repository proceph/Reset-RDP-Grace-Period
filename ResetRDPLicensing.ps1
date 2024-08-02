#Script pour reset la période d'essai du RDP, à utiliser en dev seulement

#Attribution des droits et suppression de la clé: 
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
$acl = $key.GetAccessControl()
$user = whoami
$acl.SetOwner([System.Security.Principal.NTAccount]"$user")
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("$user","FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)
Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'

# puis relancer les deux services
net stop TermService /y
net start TermService /y

