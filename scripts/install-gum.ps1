# Install a pinned official Gum build inside this project, without changing PATH.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolDirectory = Join-Path $projectRoot '.bin'
$version = '2.0.2'
$archiveName = "gum_${version}_Windows_x86_64.zip"
$releaseUrl = "https://github.com/charmbracelet/gum/releases/download/v$version"
New-Item -ItemType Directory -Force -Path $toolDirectory | Out-Null
$archivePath = Join-Path $toolDirectory $archiveName
$checksumsPath = Join-Path $toolDirectory 'checksums.txt'
Invoke-WebRequest "$releaseUrl/$archiveName" -OutFile $archivePath -UseBasicParsing
Invoke-WebRequest "$releaseUrl/checksums.txt" -OutFile $checksumsPath -UseBasicParsing
$checksumLine = Get-Content -LiteralPath $checksumsPath | Where-Object { ($_ -split '\s+')[-1] -eq $archiveName }
if (-not $checksumLine) { throw 'Official checksum not found.' }
$expectedHash = ($checksumLine -split '\s+')[0]
$actualHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash
if ($actualHash -ne $expectedHash) { throw 'Checksum mismatch; Gum was not installed.' }
Expand-Archive -LiteralPath $archivePath -DestinationPath $toolDirectory -Force
$gumBinary = Get-ChildItem -LiteralPath $toolDirectory -Recurse -Filter gum.exe | Select-Object -First 1
if (-not $gumBinary) { throw 'gum.exe was not found in the release archive.' }
$targetBinary = Join-Path $toolDirectory 'gum.exe'
if ($gumBinary.FullName -ne $targetBinary) { Copy-Item -LiteralPath $gumBinary.FullName -Destination $targetBinary }
& $targetBinary --version
