$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File "C:\Workspace\Projects\nanoclaw\start-nanoclaw.ps1"' `
    -WorkingDirectory 'C:\Workspace\Projects\nanoclaw'

$trigger = New-ScheduledTaskTrigger -AtLogOn

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 5 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

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
    -Force

Write-Output "REGISTERED_OK: Task 'NanoClaw' created."
