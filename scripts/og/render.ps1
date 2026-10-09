# Renders scripts/og/og.html into assets/img/og.png, the share image.
# Run it from PowerShell after changing og.html:  .\scripts\og\render.ps1
# Edge needs its own profile folder, otherwise it hands the job to an
# Edge window that is already open and never writes the file.

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$page = 'file:///' + ((Join-Path $PSScriptRoot 'og.html') -replace '\\', '/' -replace ' ', '%20')
$out = Join-Path $root 'assets\img\og.png'
$profileDir = Join-Path $env:TEMP 'og-render-edge'

$edge = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge was not found.' }

if (Test-Path $out) { Remove-Item $out }
# Edge prints harmless warnings on stderr, so they go to a log file instead
# of being treated as errors by PowerShell.
$edgeArgs = @('--headless=new', '--disable-gpu', '--hide-scrollbars', "--user-data-dir=`"$profileDir`"",
  '--window-size=1200,630', '--virtual-time-budget=3000', "--screenshot=`"$out`"", $page)
Start-Process -FilePath $edge -ArgumentList $edgeArgs -Wait -WindowStyle Hidden `
  -RedirectStandardError (Join-Path $env:TEMP 'og-render-edge.log')

for ($i = 0; $i -lt 20 -and -not (Test-Path $out); $i++) { Start-Sleep -Milliseconds 250 }
if (-not (Test-Path $out)) { throw "Edge did not write $out" }
Write-Output "Wrote $out"
