---
uid: mongodb-installation
---

# MongoDB Installation

By default, the Wayk Bastion PowerShell module creates MongoDB container and a Docker volume to store its data. While this may be good enough for most, a regular MongoDB installation is preferable, especially if high availability is required.

## Windows

Download the [MongoDB .msi installer for Windows](https://www.mongodb.com/try/download/community).

![MongoDB download](../../images/mongo_windows_download.png)

Launch the .msi installer, then click Next.

![MongoDB Windows installer 1](../../images/mongo_windows_installer_1.png)

Accept the license agreement, then click Next.

![MongoDB Windows installer 2](../../images/mongo_windows_installer_2.png)

Leave the default options, then click Next.

![MongoDB Windows installer 3](../../images/mongo_windows_installer_3.png)

If you wish to install MongoDB Compass, check "Install MongoDB Compass", then click Next. While it is a very convenient MongoDB GUI, it can take several minutes to install.

![MongoDB Windows installer 4](../../images/mongo_windows_installer_4.png)

Click Install to begin the installation.

![MongoDB Windows installer 5](../../images/mongo_windows_installer_5.png)

Wait for the installation to complete. If you selected MongoDB Compass, it will take a few minutes, so be patient.

![MongoDB Windows installer 6](../../images/mongo_windows_installer_6.png)

Click Finish to complete the installation.

![MongoDB Windows installer 7](../../images/mongo_windows_installer_7.png)

That's it, you should now have a "MongoDB" system service started automatically, with files stored under "C:\Program Files\MongoDB\Server".

## Migrating to an external database

If you have been using the internal database automatically created as a Windows container, follow these steps to migrate your data and switch to the new MongoDB database server.

```powershell
Enter-WaykBastion -ChangeDirectory
Stop-WaykBastion
$BackupFile = $(Get-Date -Format FileDataUniversal)
Backup-WaykBastionData -BackupPath ".\${BackupFile}"
```

In order to perform MongoDB management on the host, you will need to install the [MongoDB management tools](https://docs.mongodb.com/database-tools/installation/).

Download the [.msi installer](https://www.mongodb.com/try/download/database-tools) or equivalent package for your platform:

![MongoDB Windows Tools](../../images/mongo_windows_tools.png)

Once installed, the tools should be located in directory that looks like "C:\Program Files\MongoDB\Tools\100\bin".
