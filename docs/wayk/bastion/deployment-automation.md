---
uid: deployment-automation
---

# Deployment Automation

Once you have a Wayk Bastion server ready, the next step is to find a way to automate the process of installing, registering and configuring Wayk Agent on all of the machines you need to manage. This process is important in order to reduce the total number of manual operations that one needs to perform, especially if you have a large number of machines.

## Installation

Wayk Agent should be installed using the .msi installer on Windows, or the .pkg installer on macOS. You cannot use the standalone executable on Windows or the .dmg package on macOS for unattended access, as they are only meant for temporary access. As such, Wayk is not an agentless product because you need to install Wayk Agent.

If you already have a tool that can push the installer on your machines and install it this way, you can download the packages from our CDN and do the installation this way.

If you do not have a way of pushing the installer on the remote machines but can get them to execute scripts, such as logon scripts pushed through GPO in a Windows domain, we recommend automating the downloading of the package from our CDN.

The downloading and installing of the Wayk Agent package is already automated in our [WaykAgent PowerShell module available on PSGallery](https://www.powershellgallery.com/packages/WaykAgent). This cmdlet is compatible with PowerShell 7 (and Windows PowerShell 5.1) and works on all operating systems (Windows, macOS, Linux).

If you would rather make your own script to do the same thing without using the cmdlet, simply use the PowerShell code available on GitHub as reference to roll your own.

## Enrollment

The enrollment token is used to authorize machines to join your Wayk Bastion and automatically register for unattended access. This token is meant to be easily embedded within scripts, such that all you need is to run a command to get Wayk Agent to register with a specific Wayk Bastion initially.

To create a new enrollment token, go in "Servers → Machine Registration", then click the "Generate".

![New Enrollment Token](../../images/den_enrollment_token_new.png)

You can set a validity period for the token, or you can also disable token expiration by setting it to *Never*. If you want to keep using a token after it has expired, there is always the possibility of renewing it.

To simplify group management, you can also select in which group machines using this token will be put. If you want to automatically enroll different machines in different groups, simply create more than one token and use them appropriately.

Click "Generate" to create the enrollment token with the desired options.

![Enrollment Token Id](../../images/den_enrollment_token_id.png)

You should now see the enrollment token in the list. For the moment, the only information which you need is the token id (f762156f-9470-4dcc-9ba3-157437e465ce), which can be easily embedded in an automation script.

### Enrollment Using Token Id

After installing Wayk Agent on a machine, the *wayk-now* command-line becomes available for post-installation automation. To automatically enroll Wayk Agent to your private Wayk Bastion, call the *wayk-now enroll* command with the --token-id and --den-url parameters:

    wayk-now enroll --token-id f762156f-9470-4dcc-9ba3-157437e465ce --den-url https://den.contoso.com

If the command is successful, Wayk Agent will be configured to point to your Wayk Bastion, and will be automatically registered for unattended access. It should now be visible in the list of registered machines in Wayk Bastion:

![Enrollment Token - Machine](../../images/den_enrollment_machine.png)

### Enrollment Using Token Data

While the token id is relatively short and easy to embed into a script, it has one disadvantage: it doesn’t contain information about the Wayk Bastion it belongs to. This is why the *--den-url* parameter is required when using the token id for automated enrollment.

The alternative is to extract and use the full token data, such that the only thing you need is the token. However, the token data is usually much longer and usually needs to be embedded in a file to be passed to Wayk Agent.

To extract the enrollment token data, click on the vertical ellipsis (⋮) button besides the enrollment token, and select "View full token":

![Enrollment Token - Actions](../../images/den_enrollment_token_actions.png)

The full token data will be presented for you to copy to the clipboard. This long string is a valid JSON Web Token (JWT), and its contents can be inspected by pasting it in the [jwt.io debugger tool](https://jwt.io/).

![Enrollment Token - Data](../../images/den_enrollment_token_data.png)

For automated enrollment, save this token to a file on disk (such as *C:\\token.txt*) and then use the *wayk-now enroll* command:

    wayk-now enroll --token-file C:\token.txt

Alternatively, you can also pass the full enrollment token data at the command-line, even if it is quite long:

    wayk-now enroll --token-data eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Rlbi5idXp6d29yZC5tYXJrZXRpbmciLCJqdGkiOiJmNzYyMTU2Zi05NDcwLTRkY2MtOWJhMy0xNTc0MzdlNDY1Y2UiLCJpYXQiOjE1OTcwODI3NjMsImV4cCI6MTU5OTY3NDc2M30.hWaKDCHXuCHd6dXNwkvdCVKSY3eZXN7qWKKPkeSFdT4NkhT8H-p_GNXxpXuE-OTfOFislg9F1eacV5p86ef3qukgWp_qw_LJ6O8kBcq1AQccSFM7nkyB5yvXnAFbvuOJyUnGxmGG0eO9b3ihA3RVZdQFaQrn7uDyQSAnPssq1M0tli9ywcXki__IzAFI7ZXDPZPKwEw_xedADNSNfL7Gb_pnFnTsyuSOLynq7T8TPdR0G5YSG6palnRjWKPlZeEfYhYq6qu_zDSDLDLgfLFxjSxVHUGd62cSC3r1ne5Viu7GZKZIQJR2T1ljWPBfttqYjrHZMTe6JiU3-E7VUVYLVQ

However, we recommend using a file to pass the enrollment token data whenever possible, as simple copy/paste errors are easy to make with large strings like this.

## Configuration

Once Wayk Agent is installed and registered with Wayk Bastion, you may want to change configuration settings. This can be done through the *wayk-now config* command.

These commands can be appended to your custom deployment script that installs the package, performs automated enrollment and finishes by modifying the configuration.

## Deployment

### PowerShell Module

The Wayk Agent can be installed and configured using the `WaykAgent` PowerShell module, making it easy to write a custom script for deployment automation.

```powershell
Install-Module -Name WaykAgent -Scope AllUsers -Force
Import-Module -Name WaykAgent
```

Install Wayk Agent quietly:

```powershell
Install-WaykAgent -Quiet
```

Register Wayk Agent with Wayk Bastion:

```powershell
Register-WaykAgent `
    -DenUrl "https://bastion.ad.it-help.ninja" `
    -TokenId "1be20ccc-7714-4bb7-b88a-a8a6a873f653"
```

You can find additional commands exposed by the `WaykAgent` PowerShell module using the `Get-Command -Module WaykAgent`.

### Custom Executable

The Wayk Agent can be deployed using a one-click custom executable preconfigured to install, configure and register Wayk Agent with Wayk Bastion.

Install the `WaykCustomExecutable` PowerShell module:

```powershell
Install-Module -Name WaykCustomExecutable -Scope AllUsers
Import-Module -Name WaykCustomExecutable
```

Install the [7-zip command-line tool](https://www.7-zip.org/) manually or using chocolatey (`choco install 7zip -y`). Make sure that the '7z' executable can be found in the system PATH:

```powershell
PS > where.exe 7z
C:\ProgramData\chocolatey\bin\7z.exe
```

The custom executable requires the following parameters:

* DenUrl: Wayk Bastion server URL (https)
* TokenId: Machine registration token id

The `BrandingFile` parameter is optional, but if you used the white-label editor, the resulting branding.zip file can be exported using the "save" button:

![Wayk Export branding file](../../images/wayk_export_branding_file.png)

Choose a directory in which to put all the files, here I used "C:\shared" and made it a network share for easy distribution on the local network. Run the following command to generate your first custom executable:

```powershell
New-WaykCustomExecutable `
    -DenUrl "https://bastion.ad.it-help.ninja" `
    -TokenId "1be20ccc-7714-4bb7-b88a-a8a6a873f653" `
    -BrandingFile ".\branding.zip" `
    -DestinationPath "." `
    -DestinationName "ItHelpAgent" `
    -Architecture "x64" `
    -EmbedMsi $true
```

The custom executable generation process and resulting files should look like this:

![Wayk Custom Executable](../../images/wayk_custom_executable.png)

The new "ItHelpAgent.exe" custom executable is now ready to be deployed to machines for a one-click installation.
