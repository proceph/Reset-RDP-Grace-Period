#Script for resetting rdp licensing 120 days grace period, to use only in dev env, not in prod env

#Granting access and deleting registry grace period key
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
$acl = $key.GetAccessControl()
$user = whoami
$acl.SetOwner([System.Security.Principal.NTAccount]"$user")
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("$user","FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)
Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'

# Restarting rdp services
net stop TermService /y
net start TermService /y

