<#
.SYNOPSIS
    Opens a chapter in vvvv with every package repository it needs.

.DESCRIPTION
    NEVER type the launch by hand. This pack builds nothing of its own, so every node in every
    chapter comes from a sibling repository and there are six folders to get right. Omitting one
    does not say so: vvvv IGNORES a repository folder that does not exist, and the failure surfaces
    as an error naming something else entirely. Two launches were lost to exactly that next door.

    The list itself is in Get-PackageRepositories.ps1 - one source of truth, because having it in
    two places is what caused the problem.

    OPENING A DOCUMENT IN VVVV IS RUNNING IT. Read what you came for and close the window. Never
    leave it running unattended - that is how 17,000 TCP connections happened.

.EXAMPLE
    .\tools\Open-HelpPatch.ps1 "Drawing GeoJSON"

.EXAMPLE
    .\tools\Open-HelpPatch.ps1 -List
#>
param(
    [Parameter(Position = 0)]
    [string]$Patch,

    [switch]$List,

    # Also pass --log: vvvv writes Documentsvvv\gammavvv_<timestamp>.log, the only place a
    # runtime exception inside a subpatch shows up as text (2026-08-28).
    [switch]$Log,

    # Any .vl, chapter or not - scratchpad probes take this route.
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path $PSScriptRoot -Parent
$Vvvv     = 'C:\Program Files\vvvv\vvvv_gamma_7.4-win-x64\vvvv.exe'

if (-not (Test-Path $Vvvv)) {
    Write-Host "vvvv not found at $Vvvv" -ForegroundColor Red
    exit 1
}

$helpDir  = Join-Path $RepoRoot 'help'
$chapters = @(if (Test-Path $helpDir) { Get-ChildItem $helpDir -Recurse -File -Filter *.vl }) | Sort-Object Name

if ($List -or (-not $Patch -and -not $Path)) {
    Write-Host "`nchapters in $helpDir`n"
    if ($chapters) { $chapters | ForEach-Object { Write-Host "  $($_.BaseName)" } }
    else { Write-Host "  (none yet)" }
    Write-Host "`nusage: .\tools\Open-HelpPatch.ps1 ""Drawing GeoJSON""`n"
    exit 0
}

if ($Path) {
    if (-not (Test-Path $Path)) { Write-Host "no such file: $Path" -ForegroundColor Red; exit 1 }
    $target = (Resolve-Path $Path).Path
} else {
    # Exactly one match or nothing. A launch that opens the wrong chapter wastes a whole round, and
    # vvvv reports nothing about which document it was handed.
    $hits = @($chapters | Where-Object { $_.BaseName -like "*$Patch*" })
    if ($hits.Count -eq 0) {
        Write-Host "no chapter matches '$Patch'. -List shows them." -ForegroundColor Red
        exit 1
    }
    if ($hits.Count -gt 1) {
        Write-Host "'$Patch' matches $($hits.Count) chapters:" -ForegroundColor Red
        $hits | ForEach-Object { Write-Host "  $($_.BaseName)" }
        exit 1
    }
    $target = $hits[0].FullName
}

$paths = & (Join-Path $PSScriptRoot 'Get-PackageRepositories.ps1')

if ($paths.Missing.Count -gt 0) {
    Write-Host "`nmissing package repositories - vvvv would report this as a missing PACKAGE:" -ForegroundColor Red
    $paths.Missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host ''
    exit 1
}

if (Get-Process vvvv -ErrorAction SilentlyContinue) {
    Write-Host "`nvvvv is ALREADY RUNNING. Close it first - two instances share one tile cache" -ForegroundColor Red
    Write-Host "and one set of ephemeral ports.`n" -ForegroundColor Red
    exit 1
}

Write-Host "`nopening $(Split-Path $target -Leaf)"
$paths.Repositories | ForEach-Object { Write-Host "  repo  $_" }
Write-Host ''

$vvvvArgs = @("`"$target`"", '--package-repositories', "`"$($paths.Repositories -join ';')`"")
if ($Log) { $vvvvArgs += '--log'; Write-Host ('  logging to ' + $env:USERPROFILE + '\Documents\vvvv\gamma\vvvv_<timestamp>.log') }
Start-Process -FilePath $Vvvv -ArgumentList $vvvvArgs

Write-Host "READ IT AND CLOSE IT. Opening a document in vvvv is running it." -ForegroundColor Yellow
Write-Host "  the overlay's first line goes red on a rebuild across two frames - close immediately if it does`n" -ForegroundColor Yellow
