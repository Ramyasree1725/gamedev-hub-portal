# GameDev Hub - Built-in Windows HTTP Web Server (Zero dependencies required)
param([int]$Port = 8080)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootPath = $scriptPath

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "         GAMEDEV HUB - LOCAL GAMING WEB SERVER          " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Hosting directory: $rootPath" -ForegroundColor Gray
Write-Host "Server listening at: http://localhost:$Port/" -ForegroundColor Green
Write-Host "Starting default web browser..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C in this window to stop the server anytime." -ForegroundColor Gray
Write-Host "========================================================" -ForegroundColor Cyan

# Open default browser automatically
Start-Process "http://localhost:$Port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")

try {
    $listener.Start()
} catch {
    Write-Host "Port $Port is busy, trying port 8888..." -ForegroundColor Red
    $Port = 8888
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Prefixes.Add("http://127.0.0.1:$Port/")
    $listener.Start()
    Start-Process "http://localhost:$Port/"
}

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

# User accounts store
$global:UserStore = @{
    "player1" = @{ username = "player1"; password = "password123"; email = "player1@gamedev.hub"; joined = "2026-08-30"; gamesPlayed = 12 }
}

# In-memory leaderboard store with seed data
$global:LeaderboardStore = @{
    "snake"     = [System.Collections.ArrayList]@(
        [PSCustomObject]@{ name = "Alex"; score = 180; date = "2026-08-30" },
        [PSCustomObject]@{ name = "Sam"; score = 140; date = "2026-08-29" },
        [PSCustomObject]@{ name = "Jordan"; score = 90; date = "2026-08-28" }
    )
    "tictactoe" = [System.Collections.ArrayList]@(
        [PSCustomObject]@{ name = "player1"; score = 5; date = "2026-08-30" },
        [PSCustomObject]@{ name = "Sam"; score = 3; date = "2026-08-29" }
    )
    "memory"    = [System.Collections.ArrayList]@(
        [PSCustomObject]@{ name = "Casey"; score = 480; date = "2026-08-30" },
        [PSCustomObject]@{ name = "Taylor"; score = 360; date = "2026-08-29" }
    )
    "breakout"  = [System.Collections.ArrayList]@(
        [PSCustomObject]@{ name = "Morgan"; score = 1200; date = "2026-08-30" },
        [PSCustomObject]@{ name = "Riley"; score = 850; date = "2026-08-29" }
    )
    "pong"      = [System.Collections.ArrayList]@(
        [PSCustomObject]@{ name = "Alex"; score = 5; date = "2026-08-30" },
        [PSCustomObject]@{ name = "Sam"; score = 5; date = "2026-08-29" }
    )
}

function Send-JsonResponse($response, $data, [int]$statusCode = 200) {
    $jsonStr = $data | ConvertTo-Json -Depth 5 -Compress
    $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)
    $response.StatusCode = $statusCode
    $response.ContentType = "application/json; charset=utf-8"
    $response.ContentLength64 = $jsonBytes.Length
    $response.OutputStream.Write($jsonBytes, 0, $jsonBytes.Length)
    $response.Close()
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # CORS Headers
        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        $response.AddHeader("Access-Control-Allow-Headers", "Content-Type")

        if ($request.HttpMethod -eq "OPTIONS") {
            $response.StatusCode = 200
            $response.Close()
            continue
        }

        $rawUrl = $request.RawUrl
        if ($rawUrl -match "\?") {
            $rawUrl = $rawUrl.Substring(0, $rawUrl.IndexOf("?"))
        }

        # API: Health check
        if ($rawUrl -eq "/api/health") {
            Send-JsonResponse $response @{ status = "ok"; games = 5; platform = "Windows Native Engine"; timestamp = (Get-Date).ToString("s") }
            continue
        }

        # API: User Registration
        if ($rawUrl -eq "/api/auth/register" -and $request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
            $body = $reader.ReadToEnd()
            $reader.Close()

            $parsed = $null
            try { $parsed = $body | ConvertFrom-Json } catch {}

            if ($parsed -and $parsed.username -and $parsed.password) {
                $uName = ([string]$parsed.username).Trim().ToLower()
                $pwd = [string]$parsed.password
                $email = if ($parsed.email) { [string]$parsed.email } else { "$uName@gamedev.hub" }

                if ($global:UserStore.ContainsKey($uName)) {
                    Send-JsonResponse $response @{ success = $false; error = "Username already taken" } 409
                } else {
                    $newUser = @{
                        username = $parsed.username.Trim()
                        password = $pwd
                        email = $email
                        joined = (Get-Date).ToString("yyyy-MM-dd")
                        gamesPlayed = 0
                    }
                    $global:UserStore[$uName] = $newUser
                    Send-JsonResponse $response @{ success = $true; user = @{ username = $newUser.username; email = $newUser.email; joined = $newUser.joined } } 201
                }
            } else {
                Send-JsonResponse $response @{ success = $false; error = "Missing username or password" } 400
            }
            continue
        }

        # API: User Login
        if ($rawUrl -eq "/api/auth/login" -and $request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
            $body = $reader.ReadToEnd()
            $reader.Close()

            $parsed = $null
            try { $parsed = $body | ConvertFrom-Json } catch {}

            if ($parsed -and $parsed.username -and $parsed.password) {
                $uName = ([string]$parsed.username).Trim().ToLower()
                $pwd = [string]$parsed.password

                if ($global:UserStore.ContainsKey($uName) -and $global:UserStore[$uName].password -eq $pwd) {
                    $u = $global:UserStore[$uName]
                    Send-JsonResponse $response @{ success = $true; user = @{ username = $u.username; email = $u.email; joined = $u.joined } } 200
                } else {
                    Send-JsonResponse $response @{ success = $false; error = "Invalid username or password" } 401
                }
            } else {
                Send-JsonResponse $response @{ success = $false; error = "Missing username or password" } 400
            }
            continue
        }

        # API: Game list
        if ($rawUrl -eq "/api/games") {
            $games = @(
                @{ id = "snake"; name = "Snake"; desc = "Grid navigation and length growth"; difficulty = "Normal" },
                @{ id = "tictactoe"; name = "Tic Tac Toe"; desc = "Turn-based tactical grid vs AI"; difficulty = "Normal" },
                @{ id = "memory"; name = "Memory Match"; desc = "Flip and match symbol pairs"; difficulty = "Normal" },
                @{ id = "breakout"; name = "Breakout"; desc = "Paddle brick breaker physics"; difficulty = "Hard" },
                @{ id = "pong"; name = "Pong"; desc = "Classic table tennis vs AI"; difficulty = "Hard" }
            )
            Send-JsonResponse $response $games
            continue
        }

        # API: Get leaderboard
        if ($rawUrl -eq "/api/leaderboard" -or $rawUrl -eq "/api/leaderboard/") {
            Send-JsonResponse $response $global:LeaderboardStore
            continue
        }

        if ($rawUrl -match "^/api/leaderboard/([a-zA-Z0-9]+)$") {
            $gId = $Matches[1].ToLower()
            if ($global:LeaderboardStore.ContainsKey($gId)) {
                Send-JsonResponse $response $global:LeaderboardStore[$gId]
            } else {
                Send-JsonResponse $response @{ error = "Game not found" } 404
            }
            continue
        }

        # API: Post score
        if ($rawUrl -eq "/api/score" -and $request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
            $body = $reader.ReadToEnd()
            $reader.Close()

            $parsed = $null
            try { $parsed = $body | ConvertFrom-Json } catch {}

            if ($parsed -and $parsed.game) {
                $gId = [string]$parsed.game.ToLower()
                $pName = if ($parsed.name) { [string]$parsed.name.Trim() } else { "Player" }
                $pScore = if ($parsed.score -ne $null) { [int]$parsed.score } else { 0 }
                $pDate = (Get-Date).ToString("yyyy-MM-dd")

                if (-not $global:LeaderboardStore.ContainsKey($gId)) {
                    $global:LeaderboardStore[$gId] = [System.Collections.ArrayList]@()
                }

                $newEntry = [PSCustomObject]@{ name = $pName; score = $pScore; date = $pDate }
                [void]$global:LeaderboardStore[$gId].Add($newEntry)

                # Sort descending & cap at top 30
                $sorted = $global:LeaderboardStore[$gId] | Sort-Object -Property score -Descending | Select-Object -First 30
                $global:LeaderboardStore[$gId] = [System.Collections.ArrayList]@($sorted)

                Send-JsonResponse $response @{ success = $true; saved = $true; game = $gId }
            } else {
                Send-JsonResponse $response @{ success = $false; error = "Invalid payload" } 400
            }
            continue
        }

        # Static File Serving
        $localRel = $rawUrl.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($localRel) -or $localRel -eq "games" -or $localRel -eq "leaderboard" -or $localRel -eq "login" -or $localRel -eq "register") {
            $localRel = "index.html"
        }

        $filePath = Join-Path $rootPath $localRel

        if (-not (Test-Path $filePath -PathType Leaf)) {
            $filePath = Join-Path $rootPath "index.html"
        }

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = "application/octet-stream"
            if ($mimeTypes.ContainsKey($ext)) {
                $mime = $mimeTypes[$ext]
            }

            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentType = $mime
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }

        $response.Close()
    } catch {
        # continue listening
    }
}
