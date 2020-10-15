---
uid: wayk-agent-diagnostics
---

# Wayk Agent Diagnostics

## Enable Diagnostic Logging

From the Wayk Agent menu, click *Help* then check "Diagnostic Logging":

![Wayk Agent Diagnostic Logging](../../images/wayk_agent_diagnostic_logging.png)

For the changes to take effect, the Wayk Agent service needs to be restarted. Open the Windows service manager (Windows Key + R, type 'services.msc', press Enter). From the list of services, right-click "Wayk Now Unattended Service", then select "Restart".

![Wayk Agent Restart Service](../../images/wayk_agent_restart_service.png)

Alternatively, you can run `Restart-Service WaykNowService` from an elevated PowerShell terminal.

## Export Diagnostic Logs

From the Wayk Agent menu, click *Help* then *Export Diagnostics*:

![Wayk Agent Export Diagnostics](../../images/wayk_agent_export_diagnostics.png)

Select a directory (such as "My Documents"), then click OK. You should now find a .zip file containing the Wayk Agent log files:

![Wayk Agent Exported Diagnostic Logs](../../images/wayk_agent_exported_diagnostic_logs.png)

This .zip file can then be sent to our support team to help us diagnose issues.
