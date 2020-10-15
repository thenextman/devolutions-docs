---
uid: wayk-docker-installation
---

# Docker Installation

Wayk Bastion is a product composed of multiple services shipped as Docker containers for Windows and Linux, which is why you need a working Docker environment to get started. We recommend choosing one of the two following combinations:

* Windows Server 2019 + Windows Containers
* Ubuntu Linux 18.04 LTS + Linux Containers

Other versions of Windows *may* work, but we do not support them officially. We recommend Ubuntu Linux because it is was we use, but other Linux distributions such as Red Hat Enterprise Linux (RHEL) should work the same.

## Windows

When in Rome, do as the Romans do: use Windows containers on Windows. Real Windows containers are best supported in Windows Server 2019, which is why we make it a requirement for Windows. Other versions of Windows have important Docker limitations and are therefore not officially supported.

>[!WARNING]
> Many antivirus software vendors do not provide suitable Docker for Windows exclusions by default, breaking the Docker engine, severely degrading container performance, and even corrupting database files.

### Windows Server 2019

The official way of running Wayk Bastion on Windows Server is to use the built-in support for Windows containers instead of installing Docker Desktop for Windows and running Linux containers. If you intend to run Wayk Bastion inside a virtual machine, using Windows Server and Windows containers is the recommended approach because it does not require Docker Desktop for Windows and a Hyper-V virtual machine.

Install or update NuGet and PowerShellGet:

    $ Install-PackageProvider -Name NuGet -Force
    $ Install-Module -Name PowerShellGet -Force

Check if the Windows Server *Containers* feature is installed, then install it:

    $ Get-WindowsFeature | Where-Object { $_.Name -Like 'Containers' }
    $ Install-WindowsFeature -Name Containers -Restart

Install the Microsoft Docker provider:

    $ Install-Module -Name DockerMsftProvider -Force
    $ Install-Package -Name docker -ProviderName DockerMsftProvider -Force

Start the docker service if it is not currently running:

    $ Get-Service | Where-Object { $_.Name -Like 'docker' }
    $ Start-Service -Name docker

### Windows 10

On Windows 10, the recommended option is to use [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows). This version of Docker requires Hyper-V for Linux container support, making it suitable for testing on a physical machine, but not so much for a virtual machine because of limited support of Docker Desktop for Windows in virtualized environments. If you want to try Wayk Bastion inside a virtual machine, use Windows Server 2019 instead with Windows containers.

One important thing to know about Docker for Windows is that you need to [switch to Windows containers](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers) instead of the default (Linux containers). Trying to launch Windows containers when Linux containers are enabled will result in a "no matching manifest for windows/amd64" error.

For bind mount support with Linux containers on Windows, you need to go in the Docker settings and [select the required drives from the "Shared Drives" section](https://rominirani.com/docker-on-windows-mounting-host-directories-d96f3f056a2c).

## Linux

On Linux, follow one of the [distribution-specific getting started guides](https://docs.docker.com/install/linux/docker-ce/ubuntu/), then do not forget to [add your user to the docker group](https://docs.docker.com/install/linux/linux-postinstall/) after installation.

To confirm that Docker is up and running, use the `docker run hello-world` command. If you don’t see the "Hello from Docker!" message, something is wrong with your Docker installation.

## macOS

On macOS, follow the official [Docker Desktop getting started guide](https://docs.docker.com/docker-for-mac/). While macOS is not an officially supported platform for Wayk Bastion, it is suitable for testing.

## Antivirus

>[!WARNING]
> Many antivirus software vendors do not provide suitable Docker for Windows exclusions by default, breaking the Docker engine, severely degrading container performance, and even corrupting database files.

Okay, the above warning may come off as scary, but it is not as bad as it sounds. Containers are by nature running *isolated* from the host, something much better than traditional software that runs *directly* on the host.

### File Scan Exclusion

Following the [recommendation made by Docker](https://docs.docker.com/engine/security/antivirus/), add `%ProgramData%\Docker` to the list of file scan exclusions. This will prevent your antivirus from scanning container images and container volumes. These are large files that the antivirus should not lock, modify or delete in any case anyway.

Because the antivirus locks the files as it scans them, Docker is much slower at launching the containers that are composed of a layered file system (very large for Windows containers). As for database files, similar exclusions are commonly required when running database software on the host, so this is just the equivalent for containers.

### Symantec Endpoint Protection (SEP)

The "Application and Device Control (ADC) component of Symantec Endpoint Protection (SEP) is known to break the Docker engine and should be removed entirely.

Additional exclusions are also required and [documented here](https://knowledge.broadcom.com/external/article?legacyId=TECH246815). Finally, you can refer to the [following blog post](https://mdaslam.wordpress.com/2017/05/23/docker-container-windows-2016-server-with-sep-symantec-endpoint-protection/) for further guidance.

### Sophos Endpoint Protection

Sophos Endpoint Protection should work fine as long as `%ProgramData%\Docker` is added to the file scan exclusion list. Surprisingly, Sophos does not seem to document a recommended Docker for Windows exclusion procedure.

### Cisco Advanced Malware Protection (AMP)

We've had one instance where Cisco AMP broke Docker for a customer, and the problem went away after disabling it entirely. If you use Cisco AMP and figure out how to make it work with Docker, please let us know, as we couldn't find a clear answer on the Cisco website.

### Other Antivirus Software

If you don't see instructions specific to your antivirus software and run into issues, try disabling it temporarily, and then search for exclusion recommendations from your antivirus vendor. It is hard to test for all antivirus software out there, so we welcome contributions to keep the list up to date.
