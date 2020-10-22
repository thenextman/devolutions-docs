---
uid: wayk-migration-guide
---

# Migration Guide

## Wayk Den to Wayk Bastion (2020.3.0)

Open a new PowerShell terminal, import the `WaykDen` module and move to the configuration directory:

```powershell
Import-Module -Name WaykDen
Set-Location "$Env:ProgramData\Devolutions\Wayk Den"
```

If the `WaykDen` service was previously created with the `Register-WaykDenService` command, it needs to be stopped and removed:

```powershell
Stop-Service WaykDen
Unregister-WaykDenService
```

Verify that `docker ps` shows no running containers, then close the current PowerShell terminal, and open a new one in which the `WaykDen` module is not loaded. Uninstall the `WaykDen` module, then install the `WaykBastion` module to replace it:

```powershell
Uninstall-Module -Name WaykDen -AllVersions
Install-Module -Name WaykBastion -AllowClobber
```

Confirm that the `WaykBastion` module is installed, and that old versions of the `WaykDen` module were correctly uninstalled:

```powershell
PS > Get-InstalledModule Wayk* | Select-Object Name, Version

Name        Version
----        -------
WaykBastion 2020.3.0
```

Rename the "Wayk Den" directory to "Wayk Bastion":

```powershell
Set-Location "$Env:ProgramData\Devolutions"
PS C:\ProgramData\Devolutions> Move-Item ".\Wayk Den" ".\Wayk Bastion"
```

Move to the "Wayk Bastion" configuration directory, then try launching Wayk Bastion at least once:

```powershell
Set-Location "$Env:ProgramData\Devolutions\Wayk Bastion"
Import-Module -Name WaykBastion
Start-WaykBastion -Verbose
```

If you haven't updated Wayk Bastion for some time, the `Start-WaykBastion` may take a few minutes to complete as it pulls the new containers.

The `WaykBastion` service can now be registered with the `Register-WayBastionService` again (optional):

```powershell
PS C:\ProgramData\Devolutions\Wayk Bastion> Register-WaykBastionService
"WaykBastion" service has been installed to "C:\ProgramData\Devolutions\Wayk Bastion"
PS > Start-Service WaykBastion
```
The name `WaykDen` has been renamed to `WaykBastion` in all commands, but aliases are provided for compatibility. Run `Get-Command -Module WaykBastion` to see a complete list of commands and aliases exported by the new PowerShell module.

That's it, the migration from Wayk Den to Wayk Bastion is now complete. If you encounter any issues during the migration, please do not hesitate to [contact our support](https://devolutions.net/support).
