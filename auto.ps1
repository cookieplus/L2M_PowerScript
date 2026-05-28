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

function Clear-StatusLine()
{
    Write-Host -NoNewline (
        "`r" + (" " * 120) + "`r"
    )
}

function Wait-WithCountdown($targetTimestamp)
{
    while ($true)
    {
        $now =
            [DateTimeOffset]::UtcNow.
            ToUnixTimeMilliseconds()

        $remainingMs =
            [int64]($targetTimestamp - $now)

        if ($remainingMs -le 0)
        {
            break
        }

        $timeSpan =
            [TimeSpan]::FromMilliseconds(
                $remainingMs
            )

        # mm:ss
        $timeText =
            "{0:D2}:{1:D2}" -f `
            $timeSpan.Minutes,
            $timeSpan.Seconds

        Write-Host -NoNewline (
            "`r[" +
            (Get-Date -Format "HH:mm:ss") +
            "] NEXT RUN IN -> $timeText     "
        )

        # update mỗi 200ms cho mượt hơn
        Start-Sleep -Milliseconds 200
    }

    Clear-StatusLine
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
    $startTime = Get-Date

    Log "===================================="
    Log "RUN COMBO -> $($player.Name)"
    Log "HWND      -> $($player.Hwnd)"
    Log "===================================="

    foreach ($action in $player.Config.actions)
    {
        $key = $action.key

        Send-Key $player.Hwnd $key

        if ($null -ne $action.wait_after)
        {
            Log "WAIT $($action.wait_after)s"

            Start-Sleep -Seconds (
                [double]$action.wait_after
            )
        }
    }

    $duration =
        ((Get-Date) - $startTime).TotalSeconds

    Log "COMBO DONE -> $($player.Name)"
    Log ("DURATION   -> {0:N2}s" -f $duration)
}

# =========================
# STEP 1
# FIND WINDOWS
# =========================

Log "===================================="
Log "STEP 1 - FIND WINDOWS"
Log "===================================="

$players = @()

$processes = Get-Process `
    -Name "Lineage2M" `
    -ErrorAction SilentlyContinue

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

$queue = New-Object System.Collections.ArrayList

foreach ($player in $players)
{
    try
    {
        $configPath =
            ".\configs\$($player.Name).json"

        if (-not (Test-Path $configPath))
        {
            Log "SKIP -> $($player.Name) (no config)"
            continue
        }

        $config =
            Get-Content $configPath -Raw |
            ConvertFrom-Json

        $playerObject = [PSCustomObject]@{
            Name          = $player.Name
            Hwnd          = $player.Hwnd
            Config        = $config
            NextTimestamp = 0
        }

        [void]$queue.Add($playerObject)

        Log "CONFIG LOADED -> $($player.Name)"
        Log "INTERVAL      -> $($config.loop_seconds)s"
    }
    catch
    {
        Log "CONFIG ERROR -> $($player.Name)"
        Log $_
    }
}

# =========================
# INIT QUEUE
# =========================

$baseNow =
    [DateTimeOffset]::UtcNow.
    ToUnixTimeMilliseconds()

for ($i = 0; $i -lt $queue.Count; $i++)
{
    $queue[$i].NextTimestamp =
        $baseNow - (1000 - $i)
}

# =========================
# MAIN LOOP
# =========================

Log "===================================="
Log "AUTO RUNNING"
Log "PRESS CTRL + C TO STOP"
Log "===================================="

while ($true)
{
    # sort queue
    $queue =
        $queue |
        Sort-Object NextTimestamp

    Log "=========== QUEUE DUMP ==========="

    foreach ($item in $queue)
    {
        $date =
            [DateTimeOffset]::FromUnixTimeMilliseconds(
                [int64]$item.NextTimestamp
            ).LocalDateTime

        Log (
            $item.Name +
            " | " +
            $item.NextTimestamp +
            " | " +
            $date.ToString("HH:mm:ss")
        )
    }

    Log "=================================="


    # lấy head queue
    $player = $queue[0]

    $now =
        [DateTimeOffset]::UtcNow.
        ToUnixTimeMilliseconds()

    # overdue => xử lý ngay
    if ($player.NextTimestamp -le $now)
    {
        Log ""
        Log "NEXT PLAYER -> $($player.Name)"

        Run-Combo $player

        # update timestamp
        $player.NextTimestamp =
            [DateTimeOffset]::UtcNow.
            ToUnixTimeMilliseconds() +
            (
                [double]$player.Config.loop_seconds *
                1000
            )

        $nextDate =
            [DateTimeOffset]::FromUnixTimeMilliseconds(
                [int64]$player.NextTimestamp
            ).LocalDateTime

        Log (
            "NEXT RUN -> " +
            $nextDate.ToString("HH:mm:ss")
        )

        Log ""

        continue
    }

    # chưa tới giờ => countdown
    Wait-WithCountdown $player.NextTimestamp
}
