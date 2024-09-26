$definition = @"
using System;
using System.Runtime.InteropServices; 
namespace Win32Api
{
	public class NtDll
	{
		[DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
		public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
	}
}
"@ 

Add-Type -TypeDefinition $definition -PassThru

$bEnabled = $false

## Enable SeTakeOwnershipPrivilege
$res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled)

## Take Ownership on the Key
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
$acl = $key.GetAccessControl()
$user = whoami
$acl.SetOwner([System.Security.Principal.NTAccount]"$user")
$key.SetAccessControl($acl)

## Assign Full Controll permissions to $user on the key.
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("$user","FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

## Finally Delete the key which resets the Grace Period counter to 120 Days.
Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'

# Restarting rdp services
net stop TermService /y
net start TermService /y