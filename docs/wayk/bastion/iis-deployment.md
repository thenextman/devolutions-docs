---
uid: iis-deployment
---

# IIS Deployment

Deploying Wayk Bastion behind IIS is possible with the URL Rewrite and Application Request Routing (ARR) modules. IIS is not necessarily the recommended deployment option for Wayk Bastion ([traefik](https://containo.us/traefik/), [nginx](https://www.nginx.com/) and [haproxy](http://www.haproxy.org/) are worthy alternatives). However, if you are comfortable with IIS or if you need it to deploy additional applications that require IIS within the same server, then it should be a good choice.

## IIS Feature Installation

Open a PowerShell prompt and install the base IIS features required (IIS server + WebSocket support + management tools)

    $Features = @(
        'Web-Server',
        'Web-WebSockets',
        'Web-Mgmt-Tools')

    foreach ($Feature in $Features) {
        Install-WindowsFeature -Name $Feature
    }

You can install additional features, but the most important not to forget is the WebSocket protocol support:

![IIS feature installation](../../images/iis_install_features.png)

As for the IIS graphical management tools, they are recommended but not required, and they are absent from Windows Server Core.

## IIS Module Installation

The two IIS modules we need (URL Rewrite and Application Request Routing) are not available as IIS features, and need to be installed using the [Web Platform Installer](https://www.microsoft.com/web/downloads/platform.aspx).

Once you have the Web Platform Installer, install (in order) the URL Rewrite and the Application Request Routing modules:

[IIS URL Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite)

![IIS URL Rewrite Module](../../images/iis_url_rewrite_module.png)

[IIS Application Request Routing Module](https://www.iis.net/downloads/microsoft/application-request-routing)

![IIS ARR Module](../../images/iis_arr_module.png)

Alternatively, you can install the modules using [chocolatey](https://chocolatey.org/install):

    choco install urlrewrite -y
    choco install iis-arr -y

However, the IIS URL Rewrite and Application Request Routing (ARR) modules are difficult to install automatically, so results may vary. The GUI installation is the most guaranteed to work.

## IIS Global Configuration

By default, IIS does not preserve the HTTP Host header when proxying requests, which breaks Wayk Bastion. The *preserveHostHeader* setting in the *system.webServer/proxy* section of the configuration needs to be set to *true*:

![IIS Preserve Host Header](../../images/iis_preserve_host_header.png)

Alternatively, the same modification can be done at the command line:

    %windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/proxy -preserveHostHeader:true /commit:apphost

## IIS Site Configuration

In IIS manager, right-click "Sites" and select "Add Website.."

![IIS Add Website](../../images/iis_add_website.png)

In the "Add Website" dialog, enter a site name, physical path and host name. Make sure that the host name you choose is the final one you expect to use with https and matches your certificate name.

As for the physical path on disk, it is not going to be used, but IIS requires you to have one. I have created "C:\\inetpub\\denroot", but you can use any path you want.

Click OK to create the new website, then select it from the list of sites on the left.

![IIS Create New Site](../../images/iis_create_new_site.png)

With the correct site selected on the left, find the "URL Rewrite" feature and double-click to open it:

![IIS URL Rewrite - Open](../../images/iis_url_rewrite_open.png)

Under "Actions" at the top right, click "Add Rule(s)…". In the "Add Rule(s)" dialog, select "Reverse Proxy" and then click OK.

![IIS URL Rewrite - Add Rule](../../images/iis_url_rewrite_add_rule.png)

While creating the new reverse proxy rule, you will likely be asked to enable proxy functionality (Application Request Routing). Click OK to enable it:

![IIS Enable ARR](../../images/iis_enable_arr.png)

You should now see a single rule called "ReverseProxyInboundRule1" in the list. Double-click on it to open the "Edit Inbound Rule" view.

In the "Match URL" section, leave the "(.\*)" default pattern value. Go to the "Conditions" section and then click "Add…" to create a new condition:

![IIS URL Rewrite - Cache URL Condition](../../images/iis_url_rewrite_cache_url.png)

The final result should look like this:

![IIS URL Rewrite - Edit Inbound Rule](../../images/iis_url_rewrite_edit_inbound_rule.png)

With this URL Rewrite inbound rule, we can now properly rewrite https:// and wss:// URLs to localhost http:// and ws:// URLs. This is important, as failing to correctly rewrite the WebSocket URLs will break WebSocket connectivity, which is required.

While obtaining a proper server certificate is outside of the scope of this guide, you still need to import it in IIS before configuring an HTTPS site binding for your site. Locate the "Server Certificates" feature and double-click on it to open it:

![IIS Server Certificates](../../images/iis_server_certificates.png)

At the top right, under "Actions", click "Import…".

![IIS - Import Certificate](../../images/iis_import_certificate.png)

In the "Import Certificate" dialog, select your certificate in .pfx file, enter the password and then click OK.

You can now create a new HTTPS site binding. Under "Sites", right-click your site (*den.buzzword.marketing* in this case) and then select "Edit Bindings…":

![IIS Site - Edit Bindings](../../images/iis_site_edit_bindings.png)

In the "Site Bindings" dialog, click "Add…":

![IIS HTTPS site binding](../../images/iis_https_site_binding.png)

Select "https" as the binding type, and enter your IIS site host name. Check "Require Server Name Indication" and "Disable HTTP/2". Click "Select…", then select the server certificate that was previously imported. Click OK to create the new site binding.

That’s it! Your IIS site is now ready. Review your Wayk Bastion configuration ListenerUrl and ExternalUrl parameters to make sure they correspond to your current configuration:

    Set-WaykDenConfig -ListenerUrl 'http://localhost:4000' -ExternalUrl 'https://den.buzzword.marketing'

Then start Wayk Bastion, and you should now be able to access it through your IIS site. If it doesn’t work the first time, try running *iisreset* once to force the configuration changes made earlier.
