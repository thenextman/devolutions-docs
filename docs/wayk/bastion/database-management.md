---
uid: database-management
---

# Database Management

Aside from the Wayk Bastion configuration files, all Wayk Bastion data is stored inside a [MongoDB database](https://www.mongodb.com). If you do not specify a database, a simple MongoDB container will be launched with a docker volume attached to it. While this is fine for a lot of use cases, using a single MongoDB container instance is not suitable for high availability scenarios.

>[!NOTE]
> If you need help installing and configuring a MongoDB server, [use this guide instead](xref:mongodb-installation).

## External Database

To point Wayk Bastion to an existing MongoDB server, you need to configure a database connection string, and set MongoDB as external to avoid launching a MongoDB container instance:

```powershell
Set-WaykBastionConfig -MongoExternal $true -MongoUrl 'mongodb://mongo-server:27017'
```

## Database Backup

MongoDB database backups can be done using the [mongodump command-line tool](https://docs.mongodb.com/manual/reference/program/mongodump/). For simplicity, the `Backup-WaykBastionData` command can be used to streamline the process:

```powershell
Backup-WaykBastionData -BackupPath .\den-backup.tgz -Verbose
```

The `Backup-WaykBastionData` is only usable with a non-external MongoDB database. You can add the `-Verbose` parameter to show the docker commands used to call `mongodump` inside a container for reference.

## Database Restore

A MongoDB database can be restored from a backup using the [mongorestore command-line tool](https://docs.mongodb.com/manual/reference/program/mongorestore/). For obvious reasons, you should be careful about restoring a database, as the operation will overwrite the current data and replace it with the one from the backup.

Just like `Backup-WaykBastionData`, `Restore-WaykBastionData` should only be used with a non-external MongoDB database. A proper restore involves stopping Wayk Bastion, restoring data from the backup file, then restarting Wayk Bastion. Since Stop-WaykBastion stops the database container, `Restore-WaykBastionData` will automatically start it for the restore operation.

```powershell
PS > Stop-WaykBastion
PS > Restore-WaykBastionData -BackupPath ".\den-backup.tgz" -Verbose
PS > Restart-WaykBastion
```

## Changing database

It is possible to change databases without deleting the current one, by changing which docker volume is attached to the *den-mongo* container. The default docker volume name is *den-mongodata*, but you can tell Wayk Bastion to use a different one:

```powershell
PS > Stop-WaykBastion
PS > Set-WaykBastionConfig -MongoVolume 'den-testdata'
PS > Start-WaykBastion
```

After starting Wayk Bastion, you should be able to see two docker volumes:

```powershell
PS > docker volume ls
DRIVER              VOLUME NAME
local               den-mongodata
local               den-testdata
```

Since *den-testdata* is a new empty docker volume, Wayk Bastion will be the same as a fresh installation. This can be useful for safe experimentation in a temporary database without touching the "good" one.

If you want to revert back to the original database, simply change the docker volume again:

```powershell
PS > Stop-WaykBastion
PS > Set-WaykBastionConfig -MongoVolume 'den-mongodata'
PS > Start-WaykBastion
```

Where *den-mongodata* is the default docker volume name.

## Deleting database

If you want to start fresh and delete the MongoDB database entirely (use with caution!), here are the steps:

```powershell
PS > Stop-WaykBastion
PS > docker rm den-mongo
PS > docker volume rm den-mongodata
```

The above commands stop all containers, delete the *den-mongo* container currently associated with the *den-mongodata* volume, and then proceed to delete the docker volume containing the MongoDB database files.
