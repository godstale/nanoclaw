# NanoClaw startup script for Windows Task Scheduler
# Loads .env variables and starts the Node.js service with log rotation

$ProjectDir = "C:\Workspace\Projects\nanoclaw"
$LogFile    = "$ProjectDir\logs\nanoclaw.log"
$ErrFile    = "$ProjectDir\logs\nanoclaw.error.log"
$NodeExe    = "C:\Program Files\nodejs\node.exe"
$Entry      = "$ProjectDir\dist\index.js"

Set-Location $ProjectDir

# Load .env into the process environment
if (Test-Path "$ProjectDir\.env") {
    Get-Content "$ProjectDir\.env" | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name  = $Matches[1].Trim()
            $value = $Matches[2].Trim().Trim('"').Trim("'")
            [System.Environment]::SetEnvironmentVariable($name, $value, 'Process')
        }
    }
}

# Rotate logs if they exceed 10 MB
foreach ($log in @($LogFile, $ErrFile)) {
    if (Test-Path $log) {
        $size = (Get-Item $log).Length
        if ($size -gt 10MB) {
            $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
            Rename-Item $log "$log.$ts.bak"
        }
    }
}

# Start NanoClaw and tee stdout/stderr to log files
& $NodeExe $Entry *>&1 | Tee-Object -FilePath $LogFile -Append
