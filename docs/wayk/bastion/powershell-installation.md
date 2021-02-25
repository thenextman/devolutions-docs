---
uid: wayk-powershell-installation
---

# PowerShell Installation

## Windows

The `WaykBastion` PowerShell module is compatible with Windows PowerShell 5.1 (built-in), but advanced features like [Wayk PowerShell Remoting](xref:wayk-client-psremoting) require [PowerShell 7](https://docs.microsoft.com/powershell/). The Wayk Bastion host does not require PowerShell 7 unless you also intend to use Wayk Client or Wayk Agent on it for this reason.

You can download and install PowerShell 7 [following the instructions from the GitHub page](https://github.com/PowerShell/PowerShell#get-powershell), otherwise you can install it using this quick one-liner command:

```powershell
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
```

### Execution Policy

The default [PowerShell execution policy](https://docs.microsoft.com/en-ca/powershell/module/microsoft.powershell.core/about/about_execution_policies) is likely too restrictive, especially if you have never bothered configuring it before. To avoid issues, you can change the execution policy to `Unrestricted`:

```powershell
Set-ExecutionPolicy Unrestricted
```

PowerShell code signing is a feature restricted to Windows, and is not available on non-Windows PowerShell yet. If you get errors related to the execution policy, just disable it, even just temporarily.

### PowerShellGet

A fresh Windows installation often comes with an outdated version of [PowerShellGet](https://docs.microsoft.com/en-us/powershell/module/powershellget), causing issues when you try installing PowerShell modules with the `Install-Module` command the first time. Run the following in an elevated terminal to [update PowerShellGet](https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget):

```powershell
Install-PackageProvider Nuget -Force
Install-Module -Name PowerShellGet -Force
```

### Module Install Scope

Installation of PowerShell modules using the [`Install-Module` command](https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module) should always use `-Scope AllUsers`, otherwise PowerShell modules will be installed in the current user scope.

Certain features like the Wayk Bastion service wrapper also *require* a global installation of the PowerShell module. Windows PowerShell 5.1 and PowerShell 7 use different directories to install modules in the `CurrentUser` scope, but they use the same one to install modules in the `AllUsers` scope.

You can learn more about these differences in the [About PSModulePath](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath) article.

## Linux

PowerShell 7 is cross-platform and is supported on [a wide variety of Linux distributions](https://github.com/PowerShell/PowerShell#get-powershell). Follow the official instructions to [install PowerShell on Linux](https://docs.microsoft.com/en-ca/powershell/scripting/install/installing-powershell-core-on-linux) using the Microsoft package repositories.

The following code snippet can be used to streamline the installation process on Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common lsb-release
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -r -s)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo add-apt-repository universe
sudo apt-get install -y powershell
pwsh
```

### Elevated Prompt

Whenever instructions mention that commands require an "elevated prompt", simply launch a new `pwsh` instance as root with the `sudo` command:

```bash
sudo pwsh
```

You cannot run individual PowerShell commands as root with sudo, as PowerShell commands are not separate processes. The best is to create an elevated `pwsh` process only when required, an exit it once it is not no longer needed.

## macOS

Wayk Bastion is not officially supported on macOS, but Wayk Client and Wayk Agent definitely are. Follow the official instructions to [install PowerShell on macOS](https://docs.microsoft.com/en-ca/powershell/scripting/install/installing-powershell-core-on-macos). The most straightforward installation method is to use [Homebrew](https://brew.sh/):

```bash
brew install --cask powershell
```
