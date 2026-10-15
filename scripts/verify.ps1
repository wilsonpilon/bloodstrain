# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackagePath,
    [string]$ArchivePath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'hash.ps1')
$root = Split-Path -Parent $PSScriptRoot
$package = (Resolve-Path -LiteralPath $PackagePath).Path
$metadata = Get-Content -LiteralPath (Join-Path $package 'version.json') -Raw | ConvertFrom-Json
$version = $metadata.version
$binaryText = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes((Join-Path $package 'BLOODSTR.COM')))
if (-not $binaryText.Contains($version) -or -not $binaryText.Contains('BLOODSTRAIN')) {
    throw 'COM nao contem o titulo e a versao esperados.'
}
foreach ($file in @('BLOODSTR.COM', "Bloodstrain-$version.dsk", 'README.md',
    'LICENSE', 'MANUAL.md', 'CHANGELOG.md', 'RELEASE.md', 'THIRD_PARTY.md',
    'SOURCE.zip', 'SHA256SUMS.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $package $file))) {
        throw "Arquivo obrigatorio ausente: $file"
    }
}
$disk = Join-Path $package "Bloodstrain-$version.dsk"
$gameFiles = @('BLOODSTR.COM', 'INTRO.PAK')
foreach ($file in $gameFiles) {
    $filePath = Join-Path $package $file
    if (-not (Test-Path -LiteralPath $filePath)) { throw "Recurso obrigatorio ausente: $file" }
    if ($file -eq 'INTRO.PAK' -and
        (Get-Sha256 $filePath) -ne (Get-Sha256 (Join-Path $root 'assets\art\export\INTRO.PAK'))) {
        throw 'Pacote de imagens difere da exportacao validada.'
    }
}
if ((Get-Item -LiteralPath $disk).Length -ne 737280) {
    throw 'DSK nao tem os 720 KiB esperados.'
}
$scratch = Join-Path $root 'build\verify-extract'
if (Test-Path -LiteralPath $scratch) { throw 'build\verify-extract ja existe; inspecione antes de repetir.' }
New-Item -ItemType Directory -Path $scratch | Out-Null
try {
    & (Join-Path $root 'tools\local\msxdisk.exe') extract $disk -d $scratch @gameFiles
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao extrair arquivos do DSK.' }
    $extracted = @(Get-ChildItem -LiteralPath $scratch -File)
    if ($extracted.Count -ne $gameFiles.Count) { throw 'Quantidade incorreta de arquivos extraidos.' }
    foreach ($file in $gameFiles) {
        $originalHash = Get-Sha256 (Join-Path $package $file)
        if ((Get-Sha256 (Join-Path $scratch $file)) -ne $originalHash) {
            throw "Arquivo no DSK difere do original: $file"
        }
    }
}
finally { Remove-Item -LiteralPath $scratch -Recurse }

foreach ($line in Get-Content -LiteralPath (Join-Path $package 'SHA256SUMS.txt')) {
    if ($line -notmatch '^([0-9a-f]{64})  (.+)$') { throw 'Manifesto SHA256 invalido.' }
    $expected = $Matches[1]
    $file = Join-Path $package $Matches[2]
    if ((Get-Sha256 $file) -ne $expected) {
        throw "Checksum incorreto: $file"
    }
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead((Join-Path $package 'SOURCE.zip'))
try {
    foreach ($entry in @('src/main.c', 'src/ui/title.c', 'scripts/build.ps1',
        'LICENSE', 'MSXgl/LICENSE.md', 'MSXgl/engine/src/crt0/crt0_dos.asm',
        'assets/art/source/intro.js', 'docs/roteiro.md',
        'src/audio/intro_music.c', 'include/audio/intro_music.h', 'MANUAL.md')) {
        if ($null -eq $zip.GetEntry($entry)) { throw "Fonte ausente no SOURCE.zip: $entry" }
    }
    foreach ($file in @('INTRO.PAK', 'TITLE.SC5') + @(1..6 | ForEach-Object { "INTRO$_.SC5" })) {
        if ($null -eq $zip.GetEntry("assets/art/export/$file")) {
            throw "Bitmap ausente no SOURCE.zip: $file"
        }
    }
}
finally { $zip.Dispose() }
if ($ArchivePath) {
    $zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ArchivePath).Path)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $package -File -Recurse -Force) {
            $name = $file.FullName.Substring($package.Length + 1).Replace('\', '/')
            $entry = $zip.GetEntry($name)
            if ($null -eq $entry) { throw "Arquivo ausente no ZIP final: $name" }
            $stream = $entry.Open()
            $algorithm = [Security.Cryptography.SHA256]::Create()
            try {
                $hash = ([BitConverter]::ToString($algorithm.ComputeHash($stream))).Replace('-', '').ToLowerInvariant()
                if ($hash -ne (Get-Sha256 $file.FullName)) {
                    throw "Arquivo divergente no ZIP final: $name"
                }
            }
            finally {
                $algorithm.Dispose()
                $stream.Dispose()
            }
        }
    }
    finally { $zip.Dispose() }
}
Write-Host "COM, DSK, fontes e checksums verificados ($version)."
