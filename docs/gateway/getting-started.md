---
uid: gateway-getting-started
---

# Getting Started

## Prerequisites

[Docker Installation](xref:wayk-docker-installation)

Install the `DevolutionsGateway` PowerShell module:

```powershell
Install-Module -Name DevolutionsGateway
Import-Module DevolutionsGateway
```

## Configuration

Create the Devolutions Gateway configuration directory if it doesn't already exists:

```powershell
PS > Import-Module DevolutionsGateway
PS > Get-DGatewayPath
C:\ProgramData\Devolutions\Gateway
PS > New-Item -Path $(Get-DGatewayPath) -ItemType 'Directory' -Force
```

Move into the configuration directory manually, or using the Enter-DGatewayConfig command:

```powershell
PS > Enter-DGatewayConfig -ChangeDirectory
PS C:\ProgramData\Devolutions\Gateway>
```

The `Enter-DGatewayConfig` command sets the `DGATEWAY_CONFIG_PATH` environment variable that affects all commands accepting the `-ConfigPath` parameter. For this guide, we will be using the standard configuration directory.

### Gateway Hostname

By default, the Devolutions Gateway will use the default computer name (`$Env:ComputerName`) as its hostname when responding to queries. For testing on the local network, this is probably not an issue, but for external access you will need to change it to the external DNS name you intend to use:

```powershell
Set-DGatewayHostname 'jet.buzzword.marketing'
```

### Gateway Listeners

Before launching Devolutions Gateway for the first time, it is important to configure its protocol listeners with the `Set-DGatewayListeners` command:

```powershell
Set-DGatewayListeners @(
    $(New-DGatewayListener 'http://*:7171' 'http://*:7171'),
    $(New-DGatewayListener 'tcp://*:8181' 'tcp://*:8181')
    )
```

Run `Get-DGatewayListeners` to see the list of configured listeners:

```powershell
PS > Get-DGatewayListeners

InternalUrl   ExternalUrl
-----------   -----------
http://*:7171 http://*:7171
tcp://*:8181  tcp://*:8181
```

Each listener object is composed of an `InternalUrl` and `ExternalUrl` member. The internal URL is the local protocol and port on which to listen, the external URL is the external protocol and port used to expose the service externally.

Use `*` as the "host" in both URLs to use an appropriate default value, unless it needs to be set explicitly to something else. The default host for the external URL is the configured gateway hostname.

When using Devolutions Gateway on the local network, both URLs will generally be identical, so don't bother about it too much for now, we'll reconfigure them later for proper external access.

## Initial Launch

Once the initial configuration is completed, the gateway can be started with the `Start-DGateway` command. Use the `-Verbose` parameter to print the full docker commands and use them for reference if you wish to launch the container directly without the `DevolutionsGateway` module.

```powershell
PS > Start-DGateway
docker pull devolutions/devolutions-gateway:0.13.0-servercore-ltsc2019
Starting devolutions-gateway
devolutions-gateway successfully started
```

Make sure that the HTTP listener health check responds "200 OK":

```powershell
PS > $DGatewayUrl = 'http://localhost:7171'
PS > Invoke-WebRequest "$DGatewayUrl/health"

StatusCode        : 200
StatusDescription : OK
Content           : {74, 101, 116, 32...}
RawContent        : HTTP/1.1 200 OK
                    Content-Length: 59
                    Date: Thu, 22 Oct 2020 19:02:07 GMT

                    Jet instance "jet.buzzword.marketing" is alive and healthy.
Headers           : {[Content-Length, 59], [Date, Thu, 22 Oct 2020 19:02:07 GMT]}
RawContentLength  : 59
```

## Certificate Configuration

Now that Devolutions Gateway was launched once with success, we can reconfigure it for proper HTTPS access. Before going any further, stop Devolutions Gateway if it is currently running:

```powershell
Stop-DGateway
```

A valid certificate from a known authority like [letsencrypt](https://letsencrypt.org) can be obtained in various ways. The [Posh-ACME PowerShell module](https://github.com/rmbolger/Posh-ACME) is an excellent module with plugins for most DNS providers.

For the purpose of this guide, we use a wildcard certificate for "*.buzzword.marketing" as opposed to "jet.buzzword.marketing". Using a wildcard certificate has many practical advantages, but it only becomes mandatory if you intend to deploy multiple instances of Devolutions Gateway for high availability.

```powershell
$CertPath = "~\certs\!.buzzword.marketing"
Import-DGatewayCertificate -CertificateFile $(Join-Path $CertPath 'fullchain.pfx') -Password 'poshacme'
```

Let's reconfigure our protocol listeners, using 'https' rather than 'http' this time:

```powershell
Set-DGatewayListeners @(
    $(New-DGatewayListener 'https://*:7171' 'https://*:7171'),
    $(New-DGatewayListener 'tcp://*:8181' 'tcp://*:8181')
    )
```

the 'tcp' listener remains unchanged for now, but it may use the configured certificate for certain protocols. Do you recall the `Set-DGatewayHostname` command? Let's confirm that the configured hostname matches the imported certificate:

```powershell
PS > Get-DGatewayHostname
jet.buzzword.marketing
```

Our certificate valid for "*.buzzword.marketing" matches the "jet.buzzword.marketing" hostname, so there won't be a certificate name mismatch.

## External Exposure

The next step is to expose Devolutions Gateway externally on that domain name. If you have an Azure VM directly exposed to the internet, add the required inbound firewall exception. In other environments, this is done with a simple port forward in your router. If you use a reverse proxy with TLS offloading, we will cover the differences later.

For this guide, I have configured an Azure VM directly exposed on the internet with a public IP. The "buzzword.marketing" domain was configured with an A record for 'jet' pointing to the Azure VM public IP.

With this in mind, let's explain a little more the internal and external URLs:

**InternalUrl**: 'https://*:7171' expands to 'https://0.0.0.0:7171', which means "listen locally in HTTPS on all network interfaces, on port 7171".

**ExternalUrl**: 'https://*:7171' expands to "https://jet.buzzword.marketing:7171" which means "accessed externally in HTTPS, on 'jet.buzzword.marketing', port 7171"

In the end, this means traffic will flow in through "https://jet.buzzword.marketing:7171" and reach "https://internal-hostname:7171" on the internal network.

Validate the configuration, making sure that everything matches, then start Devolutions Gateway again:

```powershell
Start-DGateway
```

Cross your fingers, then try the Devolutions Gateway health check:

```powershell
Invoke-WebRequest "https://$(Get-DGatewayHostname):7171/health"


StatusCode        : 200
StatusDescription : OK
Content           : {74, 101, 116, 32...}
RawContent        : HTTP/1.1 200 OK
                    Content-Length: 59
                    Date: Thu, 22 Oct 2020 20:39:58 GMT

                    Jet instance "jet.buzzword.marketing" is alive and healthy.
Headers           : {[Content-Length, 59], [Date, Thu, 22 Oct 2020 20:39:58 GMT]}
RawContentLength  : 59
```

If the above command worked, then you have successfully configured Devolutions Gateway for external access with a valid certificate, congratulations! If not, review the previous steps to find what you missed.

## Reverse Proxy

Instead of configuring Devolutions Gateway to handle HTTPS with a certificate, a reverse proxy can be put in front to handle and offload TLS entirely. This approach is preferred if multiple web applications need to be exposed through the same entry point. Reverse proxies like [IIS (with ARR)](xref:iis-deployment), traefik, nginx and haproxy also come with advanced configuration options and better ways to handle certificate management.

When using a wildcard certificate, it becomes easy to create an HTTPS listener bound to a specific domain and forward all traffic coming through this domain to Devolutions Gateway specifically. This technique is often used to make "virtual hosts" on the same TCP port (especially 443, the standard one) using TLS Server Name Indication (SNI).

Assuming we have configured our reverse proxy to forward traffic coming in through "https://jet.buzzword.marketing" to our internal host where Devolutions Gateway is listening in HTTP on port 7171, the new configuration should look like this:

```powershell
Set-DGatewayListeners @(
    $(New-DGatewayListener 'http://*:7171' 'https://*'),
    $(New-DGatewayListener 'tcp://*:8181' 'tcp://*:8181')
    )
```

Notice that in this case, the internal URL is set to 'http', because it receives traffic in HTTP from the reverse proxy. The reverse proxy handles HTTPS, offloads TLS, then forwards the traffic in HTTP to Devolutions Gateway. Because of this, the network path taken between the reverse proxy and the target host on the local network should be restricted.

You can also choose to offload TLS, yet forward traffic over HTTPS on the internal network with a second TLS connection, but this is definitely not a requirement. This type of configuration is generally more difficult to implement and comes with an additional performance cost. Before going that route, consider *not* doing TLS offloading in the first place, and letting Devolutions Gateway handle it instead with better performance.

Last but not least, the TCP listener also needs a corresponding port forwarding configuration. In this case, TCP/8181 on jet.buzzword.marketing needs to be forward to TCP/8181 on the internal host where Devolutions Gateway is running. Don't forget to double check that the firewall has the proper inbound TCP port exception.

## Wayk Bastion

If you use Wayk Bastion, you can now reconfigure it to point to your Devolutions Gateway:

```powershell
Set-WaykBastionConfig -JetExternal $true -JetRelayUrl "https://jet.buzzword.marketing:7171"
Restart-WaykBastion
```

## Automatic Startup

If you launched Devolutions Gateway in a container, you don't need to do anything, as the default [Docker restart policy](https://docs.docker.com/config/containers/start-containers-automatically/) is set to 'always'. This can be changed with the `Set-DGatewayConfig` command:

```powershell
Set-DGatewayConfig -DockerRestartPolicy "on-failure"
```

Unlike "always", the "on-failure" restart policy only restarts the container if it fails with a non-zero exit code.
