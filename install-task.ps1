# NanoClaw Task Scheduler installer
# Run once to register the auto-start task. Prompts for UAC if needed.

$ProjectDir = "C:\Workspace\Projects\nanoclaw"

# Re-launch as admin if needed
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"$ProjectDir\start-nanoclaw.ps1`"" `
    -WorkingDirectory $ProjectDir

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 5 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew

$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName 'NanoClaw' `
    -TaskPath '\' `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description 'NanoClaw personal Claude assistant - auto-start on login' `
    -Force | Out-Null

Write-Host ""
Write-Host "NanoClaw registered successfully!" -ForegroundColor Green
Write-Host "  Task name : NanoClaw"
Write-Host "  Trigger   : At logon (auto-start)"
Write-Host "  Log file  : $ProjectDir\logs\nanoclaw.log"
Write-Host ""
Write-Host "Press Enter to start NanoClaw now..." -NoNewline
Read-Host
Start-ScheduledTask -TaskName 'NanoClaw'
Write-Host "NanoClaw started." -ForegroundColor Green
Start-Sleep -Seconds 2
