---
uid: user-management
---

# User Management

Users using Wayk Now client can log in to be authenticated with Wayk Bastion server. The server, by default, will provide a Wayk Bastion ID to any user who wants to connect to it.

To authenticate user, Wayk Bastion can be configured to use a specific user group through LDAP integration. Two options are supported: Active Directory and JumpCloud.

In order to fetch user and group information, a user with read-only LDAP access must first be created.

## Active Directory

To integrate Active Directory, here is a list of the required parameters:

-   LdapServerUrl: ldap://*ldap-server*
-   LdapUsername, LdapPassword
-   LdapUserGroup

It is important to specify the server IP since there is not DNS resolution in the docker container. The user used should be a user with only read-only access. A section below explains how to create a such user. Finally, the user group is not mandatory. If it is not specified, all users will be accepted. If it is specified, only users from that group will be able to be authenticated.

The following command will set LDAP property value for active directory.

    Set-WaykDenConfig -LdapServerType ActiveDirectory -LdapUsername ldap-user@contoso.local -LdapPassword ldap-password -LdapServerUrl ldap://ldap-server -LdapUserGroup 'Domain Users'

### User creation with read-only access

By default, a new user created in active directory has read-only access on the LDAP server. But that user is also member of the group Domain Users by default. Being member of that group is enough to be able to use that user and log on any domain’s computer. To avoid that, we suggest to use a user who is not a member of Domain Users group and has only read-only access on the LDAP server. To do that, a few steps is needed.

First, a new group has to be created, let’s say "Read-only Users". Then a new user can be created and added only to that group. After that, the new group can be set as primary group for the user. And finally, the user can be removed from the Domain Users group. This user should be used to configured WaykDen Server.

## JumpCloud

[JumpCloud](https://jumpcloud.com/) is a cloud service who help you to centralize user management. You can create users and groups then use the service call "LDAP-as-a-Service" to access those users and groups from WaykDen. You can read more on [how to use JumpCloud’s LDAP-as-a-Service](https://support.jumpcloud.com/customer/en/portal/articles/2439911-using-jumpcloud-s-ldap-as-a-service).

To integrate Jump Cloud with Wayk Bastion, here is a list of the required parameters:

-   LdapServerUrl (ldaps://ldap.jumpcloud.com:636)
-   LdapUsername, LdapPassword
-   LdapBaseDn: Distinguished Name to retrieve users and groups
-   LdapUserGroup (optional)

The LDAP server url should be set to ldaps://ldap.jumpcloud.com:636. JumpCloud provide a non secure access as well, but we don’t recommend it. A user who can read the ldap directory should be created following steps [here](https://support.jumpcloud.com/customer/en/portal/articles/2439911-using-jumpcloud-s-ldap-as-a-service#createuser). The username has to be provided with the Distinguished Name (DN), something like `uid=_LDAP_BINDING_USER_,ou=Users,o=_YOUR_ORG_ID_,dc=jumpcloud,dc=com`. The base DN is similar and should be set to `ou=Users,o=_YOUR_ORG_ID_,dc=jumpcloud,dc=com`. Finally, a user group name can be specified to limit user to that group.

The following command will set LDAP property value for JumpCloud.

    Set-WaykDenConfig -LdapServerType JumpCloud -LdapUsername "uid=ldap-user,ou=Users,o=YOUR_ORG_ID,dc=jumpcloud,dc=com" -LdapPassword ldap-password -LdapServerUrl ldaps://ldap.jumpcloud.com:636 -LdapBaseDn "ou=Users,o=YOUR_ORG_ID,dc=jumpcloud,dc=com -LdapUserGroup wayk-users"
