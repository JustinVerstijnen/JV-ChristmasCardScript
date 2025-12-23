# MERRY CHRISTMAS - Big ASCII + Sparse Matrix-style rain (PowerShell)
# Matrix characters: LIGHT BLUE (Cyan)
# Press Ctrl+C to stop.

Clear-Host
[Console]::CursorVisible = $false

# ---------------- BIG ASCII TEXT ----------------
$banner = @(
"███╗   ███╗███████╗██████╗ ██████╗ ██╗   ██╗",
"████╗ ████║██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝",
"██╔████╔██║█████╗  ██████╔╝██████╔╝ ╚████╔╝ ",
"██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██╗  ╚██╔╝  ",
"██║ ╚═╝ ██║███████╗██║  ██║██║  ██║   ██║   ",
"╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ",
"",
" ██████╗██╗  ██╗██████╗ ██╗███████╗████████╗███╗   ███╗ █████╗ ███████╗",
"██╔════╝██║  ██║██╔══██╗██║██╔════╝╚══██╔══╝████╗ ████║██╔══██╗██╔════╝",
"██║     ███████║██████╔╝██║███████╗   ██║   ██╔████╔██║███████║███████╗",
"██║     ██╔══██║██╔══██╗██║╚════██║   ██║   ██║╚██╔╝██║██╔══██║╚════██║",
"╚██████╗██║  ██║██║  ██║██║███████║   ██║   ██║ ╚═╝ ██║██║  ██║███████║",
" ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝"
)

# --------------- SETTINGS ----------------
# Higher number = fewer columns draw characters (less "full")
# Example: 3 => ~33% columns active, 4 => ~25%, 5 => ~20%
$columnDensityDivisor = 4

# Delay controls speed (higher = slower)
$sleepMs = 70

# --------------- HELPERS ----------------
function Get-CenteredTopLeft {
    param([string[]]$Lines)

    $w = [Console]::WindowWidth
    $h = [Console]::WindowHeight

    $bw = ($Lines | Measure-Object Length -Maximum).Maximum
    $bh = $Lines.Count

    $x = [Math]::Max(0, [int](($w - $bw) / 2))
    $y = [Math]::Max(0, [int](($h - $bh) / 2))

    return @($x, $y)
}

# --------------- MATRIX SETUP ----------------
$chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%&*+=-:;<>?/|\()[]{}"
$rand  = New-Object System.Random

function Random-Char {
    $chars[$rand.Next(0, $chars.Length)]
}

$width  = [Console]::WindowWidth
$height = [Console]::WindowHeight

$dropY = New-Object int[] $width
$activeCol = New-Object bool[] $width

for ($x = 0; $x -lt $width; $x++) {
    $dropY[$x] = $rand.Next(0, $height)

    # Only some columns are active => less clutter
    $activeCol[$x] = ($rand.Next(0, $columnDensityDivisor) -eq 0)
}

# --------------- BANNER MASK ----------------
$pos = Get-CenteredTopLeft -Lines $banner
$bx = $pos[0]
$by = $pos[1]

$bannerMask = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 0; $i -lt $banner.Count; $i++) {
    for ($j = 0; $j -lt $banner[$i].Length; $j++) {
        if ($banner[$i][$j] -ne ' ') {
            $bannerMask.Add("$($bx + $j),$($by + $i)") | Out-Null
        }
    }
}

function Draw-Banner {
    for ($i = 0; $i -lt $banner.Count; $i++) {
        if ($by + $i -ge 0 -and $by + $i -lt [Console]::WindowHeight) {
            [Console]::SetCursorPosition($bx, $by + $i)

            if ($i -le 5) {
                [Console]::ForegroundColor = [ConsoleColor]::Green
            }
            elseif ($i -eq 6) {
                [Console]::ForegroundColor = [ConsoleColor]::Yellow
            }
            else {
                [Console]::ForegroundColor = [ConsoleColor]::Red
            }

            [Console]::Write($banner[$i])
        }
    }
    [Console]::ResetColor()
}

Clear-Host
Draw-Banner

try {
    while ($true) {

        # If window resized, re-init (keeps it stable)
        $newW = [Console]::WindowWidth
        $newH = [Console]::WindowHeight
        if ($newW -ne $width -or $newH -ne $height) {
            $width  = $newW
            $height = $newH

            $dropY = New-Object int[] $width
            $activeCol = New-Object bool[] $width
            for ($x = 0; $x -lt $width; $x++) {
                $dropY[$x] = $rand.Next(0, $height)
                $activeCol[$x] = ($rand.Next(0, $columnDensityDivisor) -eq 0)
            }

            $pos = Get-CenteredTopLeft -Lines $banner
            $bx = $pos[0]
            $by = $pos[1]

            $bannerMask = New-Object 'System.Collections.Generic.HashSet[string]'
            for ($i = 0; $i -lt $banner.Count; $i++) {
                for ($j = 0; $j -lt $banner[$i].Length; $j++) {
                    if ($banner[$i][$j] -ne ' ') {
                        $bannerMask.Add("$($bx + $j),$($by + $i)") | Out-Null
                    }
                }
            }

            Clear-Host
            Draw-Banner
        }

        for ($x = 0; $x -lt $width; $x++) {
            if (-not $activeCol[$x]) { continue }

            $y = $dropY[$x]

            if ($y -ge 0 -and $y -lt $height) {
                $key = "$x,$y"
                if (-not $bannerMask.Contains($key)) {
                    [Console]::SetCursorPosition($x, $y)
                    [Console]::ForegroundColor = [ConsoleColor]::Cyan   # LIGHT BLUE
                    [Console]::Write((Random-Char))
                }
            }

            $dropY[$x]++
            if ($dropY[$x] -ge ($height + $rand.Next(0, 20))) {
                $dropY[$x] = 0

                # Occasionally toggle column activity so pattern changes slowly
                if ($rand.Next(0, 6) -eq 0) {
                    $activeCol[$x] = ($rand.Next(0, $columnDensityDivisor) -eq 0)
                }
            }
        }

        Draw-Banner
        Start-Sleep -Milliseconds $sleepMs
    }
}
finally {
    [Console]::CursorVisible = $true
    [Console]::ResetColor()
}
