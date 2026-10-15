# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param(
    [switch]$InitialRelease,
    [switch]$SmokeTest,
    [string]$DosFilesPath,
    [string]$BootTemplatePath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'hash.ps1')
$root = Split-Path -Parent $PSScriptRoot
if ($root -match '\s') {
    throw 'A ferramenta upstream da MSXgl usa argumentos sem aspas. Use uma pasta sem espacos.'
}
& (Join-Path $PSScriptRoot 'setup.ps1')
if ($SmokeTest -and ((-not $DosFilesPath) -or (-not $BootTemplatePath))) {
    throw 'SmokeTest exige DosFilesPath e BootTemplatePath fornecidos pelo usuario.'
}

function Invoke-Tool {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Falha em $Executable (codigo $LASTEXITCODE)."
    }
}

function New-PortableZip {
    param([string]$Directory, [string]$Destination)
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::Open($Destination, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $Directory -File -Recurse -Force) {
            $name = $file.FullName.Substring($Directory.Length + 1).Replace('\', '/')
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $archive, $file.FullName, $name,
                [IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    }
    finally { $archive.Dispose() }
}

$lockPath = Join-Path $root 'build\build.lock'
$lock = [IO.File]::Open($lockPath, [IO.FileMode]::OpenOrCreate,
    [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
try {
    $versionPath = Join-Path $root 'version.json'
    $metadata = Get-Content -LiteralPath $versionPath -Raw | ConvertFrom-Json
    if ($metadata.version -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
        throw 'version.json deve conter uma versao X.Y.Z.'
    }
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3]
    if (-not $InitialRelease) { $patch++ }
    $version = "$major.$minor.$patch"
    $releaseName = "Bloodstrain-$version"
    $releaseDir = Join-Path $root "dist\$releaseName"
    $releaseZip = "$releaseDir.zip"
    if ((Test-Path -LiteralPath $releaseDir) -or (Test-Path -LiteralPath $releaseZip)) {
        throw "Release $version ja existe. Nao sera sobrescrito."
    }

    $metadata.version = $version
    $generated = Join-Path $root 'build\generated\version.h'
    [IO.File]::WriteAllText($generated,
        "#pragma once`r`n#define BLOODSTRAIN_VERSION `"$version`"`r`n",
        [Text.Encoding]::ASCII)
    $binary = Join-Path $root 'build\obj\bloodstr.com'
    if (Test-Path -LiteralPath $binary) { Remove-Item -LiteralPath $binary }

    Push-Location $root
    try {
        Invoke-Tool (Join-Path $root 'MSXgl\tools\build\Node\node.exe') @(
            (Join-Path $root 'assets\art\source\intro.js')
        )
        Invoke-Tool (Join-Path $root 'MSXgl\tools\build\Node\node.exe') @(
            (Join-Path $root 'MSXgl\engine\script\js\build.js')
        )
    }
    finally { Pop-Location }
    if (-not (Test-Path -LiteralPath $binary)) { throw 'MSXgl nao gerou o COM.' }
    if ((Get-Item -LiteralPath $binary).Length -eq 0) { throw 'COM vazio.' }
    $map = Get-Content -LiteralPath (Join-Path $root 'build\obj\bloodstr.map') -Raw
    if ($map -notmatch '(?m)^\s*([0-9A-Fa-f]+)\s+s__HEAP\s*$' -or
        [Convert]::ToInt32($Matches[1], 16) -ge 32768) {
        throw 'Codigo e dados devem ficar abaixo de 8000h para a janela do mapper.'
    }

    $stage = Join-Path $root 'build\package'
    if (Test-Path -LiteralPath $stage) {
        throw 'build\package existe de uma tentativa anterior. Inspecione-o e remova apenas essa pasta antes de tentar novamente.'
    }
    New-Item -ItemType Directory -Path $stage | Out-Null
    Copy-Item -LiteralPath $binary -Destination (Join-Path $stage 'BLOODSTR.COM')
    Copy-Item -LiteralPath (Join-Path $root 'assets\art\export\INTRO.PAK') -Destination $stage
    foreach ($document in @('README.md', 'LICENSE', 'MANUAL.md', 'CHANGELOG.md',
        'RELEASE.md', 'THIRD_PARTY.md', 'OUTLINE.md', 'kickstart.md')) {
        Copy-Item -LiteralPath (Join-Path $root $document) -Destination $stage
    }
    Copy-Item -LiteralPath (Join-Path $root 'licenses') -Destination $stage -Recurse
    $metadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $stage 'version.json') -Encoding UTF8
    $disk = Join-Path $stage "$releaseName.dsk"
    $diskTool = Join-Path $root 'tools\local\msxdisk.exe'
    Invoke-Tool $diskTool @('create', $disk)
    Invoke-Tool $diskTool @('add', $disk, (Join-Path $stage 'BLOODSTR.COM'))
    Invoke-Tool $diskTool @('add', $disk, (Join-Path $stage 'INTRO.PAK'))
    Invoke-Tool $diskTool @('list', $disk, '-l')
    if ($SmokeTest) {
        & (Join-Path $PSScriptRoot 'smoke.ps1') -PackagePath $stage `
            -DosFilesPath $DosFilesPath -BootTemplatePath $BootTemplatePath
        Copy-Item -LiteralPath (Join-Path $root 'build\smoke\title.png') `
            -Destination (Join-Path $root "docs\screenshots\bloodstrain-$version-title.png")
        Copy-Item -LiteralPath (Join-Path $root 'build\smoke\dos.png') `
            -Destination (Join-Path $root "docs\screenshots\bloodstrain-$version-dos.png")
        Copy-Item -LiteralPath (Join-Path $root 'build\smoke\card6.png') `
            -Destination (Join-Path $root "docs\screenshots\bloodstrain-$version-card.png")
        Copy-Item -LiteralPath (Join-Path $root 'build\smoke\loading.png') `
            -Destination (Join-Path $root "docs\screenshots\bloodstrain-$version-loading.png")
    }
    Copy-Item -LiteralPath (Join-Path $root 'docs') -Destination $stage -Recurse

    $source = Join-Path $root "build\source-$version"
    New-Item -ItemType Directory -Path $source | Out-Null
    foreach ($directory in @('src', 'include', 'assets', 'data', 'docs', 'scripts', 'tests', 'licenses', '.vscode')) {
        $origin = Join-Path $root $directory
        if (Test-Path -LiteralPath $origin) {
            Copy-Item -LiteralPath $origin -Destination $source -Recurse
        }
    }
    foreach ($file in @('project_config.js', 'msxgl_config.h', 'build.bat',
        '.gitignore', 'README.md', 'LICENSE', 'MANUAL.md', 'CHANGELOG.md',
        'RELEASE.md', 'THIRD_PARTY.md', 'kickstart.md', 'OUTLINE.md')) {
        Copy-Item -LiteralPath (Join-Path $root $file) -Destination $source
    }
    $metadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $source 'version.json') -Encoding UTF8
    # Preserve the exact linked library source and the font, not just a URL.
    foreach ($directory in @('MSXgl\engine\src', 'MSXgl\engine\script',
        'MSXgl\engine\content\font')) {
        $destination = Join-Path $source (Split-Path -Parent $directory)
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $root $directory) -Destination $destination -Recurse
    }
    New-Item -ItemType Directory -Path (Join-Path $source 'MSXgl\projects\template_msx2') -Force | Out-Null
    foreach ($file in @('MSXgl\LICENSE.md', 'MSXgl\README.md',
        'MSXgl\projects\default_config.js', 'MSXgl\projects\template_msx2\msxgl_config.h')) {
        Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $source $file)
    }
    New-PortableZip $source (Join-Path $stage 'SOURCE.zip')

    $hashes = Get-ChildItem -LiteralPath $stage -File |
        Where-Object Name -ne 'SHA256SUMS.txt' |
        ForEach-Object {
            "$(Get-Sha256 $_.FullName)  $($_.Name)"
        }
    $hashes | Set-Content -LiteralPath (Join-Path $stage 'SHA256SUMS.txt') -Encoding ASCII

    New-PortableZip $stage $releaseZip
    & (Join-Path $PSScriptRoot 'verify.ps1') -PackagePath $stage -ArchivePath $releaseZip
    Move-Item -LiteralPath $stage -Destination $releaseDir
    $metadata | ConvertTo-Json | Set-Content -LiteralPath $versionPath -Encoding UTF8
    Write-Host "Release $version criado: $releaseZip"
}
finally {
    $lock.Dispose()
    Remove-Item -LiteralPath $lockPath
}
