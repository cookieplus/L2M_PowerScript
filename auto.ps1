# auto.ps1

# =========================
# LOAD WIN32 API
# =========================

if (-not ("KeyboardSender" -as [type]))
{
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class KeyboardSender
{
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool PostMessage(
        IntPtr hWnd,
        uint Msg,
        int wParam,
        int lParam
    );
}
"@
}

# =========================
# CONSTANTS
# =========================

$WM_KEYDOWN = 0x0100
$WM_KEYUP   = 0x0101

# =========================
# FUNCTIONS
# =========================

function Log($text)
{
    $time = Get-Date -Format "HH:mm:ss"

    Write-Host "[$time] $text"
}

function Send-Key($hwnd, $key)
{
    $vk = [int][char]$key.ToUpper()

    Log "SEND KEY '$key' -> HWND $hwnd"

    [KeyboardSender]::PostMessage(
        $hwnd,
        $WM_KEYDOWN,
        $vk,
        0
    ) | Out-Null

    Start-Sleep -Milliseconds 50

    [KeyboardSender]::PostMessage(
        $hwnd,
        $WM_KEYUP,
        $vk,
        0
    ) | Out-Null
}

function Run-Combo($player)
{
    Log "===================================="
    Log "RUN COMBO -> $($player.Name)"
    Log "HWND      -> $($player.Hwnd)"
    Log "===================================="

    foreach ($action in $player.Config.actions)
    {
        $key = $action.key

        Send-Key $player.Hwnd $key

        if ($action.wait_after)
        {
            Log "WAIT $($action.wait_after)s"

            Start-Sleep -Seconds $action.wait_after
        }
    }

    Log "COMBO DONE -> $($player.Name)"
}

# =========================
# STEP 1
# FIND LINEAGE2M WINDOWS
# =========================

Log "===================================="
Log "STEP 1 - FIND WINDOWS"
Log "===================================="

$players = @()

$processes = Get-Process -Name "Lineage2M" -ErrorAction SilentlyContinue

foreach ($process in $processes)
{
    try
    {
        $title = $process.MainWindowTitle

        if ([string]::IsNullOrWhiteSpace($title))
        {
            continue
        }

        $parts = $title.Split(
            ' ',
            [System.StringSplitOptions]::RemoveEmptyEntries
        )

        if ($parts.Length -eq 0)
        {
            continue
        }

        # player name = phần tử cuối
        $name = $parts[-1]

        $hwnd = $process.MainWindowHandle

        if ($hwnd -eq 0)
        {
            continue
        }

        $player = [PSCustomObject]@{
            Name = $name
            Hwnd = $hwnd
        }

        $players += $player

        Log "FOUND PLAYER -> $name ($hwnd)"
    }
    catch
    {
        Log $_
    }
}

# =========================
# STEP 2
# LOAD CONFIGS
# =========================

Log "===================================="
Log "STEP 2 - LOAD CONFIGS"
Log "===================================="

$activePlayers = @()

foreach ($player in $players)
{
    try
    {
        $configPath = ".\configs\$($player.Name).json"

        if (-not (Test-Path $configPath))
        {
            Log "SKIP -> $($player.Name) (no config)"
            continue
        }

        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        $playerObject = [PSCustomObject]@{
            Name   = $player.Name
            Hwnd   = $player.Hwnd
            Config = $config
        }

        $activePlayers += $playerObject

        Log "CONFIG LOADED -> $($player.Name)"
    }
    catch
    {
        Log "CONFIG ERROR -> $($player.Name)"
        Log $_
    }
}

# =========================
# STEP 3
# START TIMERS
# =========================

Log "===================================="
Log "STEP 3 - START TIMERS"
Log "===================================="

foreach ($player in $activePlayers)
{
    # chạy ngay lần đầu
    Run-Combo $player

    $timer = New-Object Timers.Timer

    $timer.Interval = $player.Config.loop_seconds * 1000
    $timer.AutoReset = $true
    $timer.Enabled = $true

    Register-ObjectEvent `
        -InputObject $timer `
        -EventName Elapsed `
        -MessageData $player `
        -Action {

            $player = $event.MessageData

            $time = Get-Date -Format "HH:mm:ss"

            Write-Host ""
            Write-Host "[$time] TIMER TRIGGER -> $($player.Name)"

            foreach ($action in $player.Config.actions)
            {
                $key = $action.key

                $vk = [int][char]$key.ToUpper()

                Write-Host "[$time] SEND KEY '$key' -> HWND $($player.Hwnd)"

                [KeyboardSender]::PostMessage(
                    $player.Hwnd,
                    0x0100,
                    $vk,
                    0
                ) | Out-Null

                Start-Sleep -Milliseconds 50

                [KeyboardSender]::PostMessage(
                    $player.Hwnd,
                    0x0101,
                    $vk,
                    0
                ) | Out-Null

                if ($action.wait_after)
                {
                    Write-Host "[$time] WAIT $($action.wait_after)s"

                    Start-Sleep -Seconds $action.wait_after
                }
            }

            Write-Host "[$time] COMBO DONE -> $($player.Name)"
        } | Out-Null

    Log "TIMER STARTED -> $($player.Name)"
    Log "INTERVAL -> $($player.Config.loop_seconds)s"
}

Log "===================================="
Log "AUTO RUNNING"
Log "PRESS CTRL + C TO STOP"
Log "===================================="

while ($true)
{
    Start-Sleep -Seconds 1
}
