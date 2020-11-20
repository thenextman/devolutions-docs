---
uid: wayk-migration-guide-linux
---

# Migration Guide for Linux

## Wayk Den to Wayk Bastion (2020.3.0)

Open a new PowerShell terminal, import the `WaykDen` module and move to the configuration directory, by default it is /etc/wayk-den

```powershell
Import-Module -Name WaykDen
Set-Location "/etc/wayk-den"
```

Stop `WaykDen`, and verify that `docker ps` shows no running containers, and then close the current PowerShell terminal

```powershell
Stop-WaykDen
docker ps
```

Open a new PowerShell terminal in which the `WaykDen` module is not loaded. Uninstall the `WaykDen` module, then install the `WaykBastion` module to replace it:

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
mv /etc/wayk-den /etc/wayk-bastion
```

Move to the "Wayk Bastion" configuration directory, then try launching Wayk Bastion at least once:

```powershell
Set-Location "/etc/wayk-bastion/"
Import-Module -Name WaykBastion
Start-WaykBastion -Verbose
```

If you haven't updated Wayk Bastion for some time, the `Start-WaykBastion` may take a few minutes to complete as it pulls the new containers.

The name `WaykDen` has been renamed to `WaykBastion` in all commands, but aliases are provided for compatibility. Run `Get-Command -Module WaykBastion` to see a complete list of commands and aliases exported by the new PowerShell module.

That's it, the migration from Wayk Den to Wayk Bastion is now complete. If you encounter any issues during the migration, please do not hesitate to [contact our support](https://devolutions.net/support).
