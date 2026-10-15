# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$PackagePath,
    [Parameter(Mandatory = $true)][string]$DosFilesPath,
    [Parameter(Mandatory = $true)][string]$BootTemplatePath,
    [string]$Emulator = 'openmsx',
    [string]$Machine = 'Philips_NMS_8255',
    [string[]]$SoundExtensions = @(),
    [ValidateRange(0, 80)][int]$MusicSeconds = 0,
    [ValidateSet(0, 50, 60)][int]$VideoHz = 0
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$package = (Resolve-Path -LiteralPath $PackagePath).Path
$dos = (Resolve-Path -LiteralPath $DosFilesPath).Path
$metadata = Get-Content -LiteralPath (Join-Path $package 'version.json') -Raw | ConvertFrom-Json
$disk = Join-Path $package "Bloodstrain-$($metadata.version).dsk"
foreach ($file in @('MSXDOS2.SYS', 'COMMAND2.COM')) {
    if (-not (Test-Path -LiteralPath (Join-Path $dos $file))) {
        throw "Forneca seus arquivos de MSX-DOS 2: $file ausente."
    }
}
$output = Join-Path $root 'build\smoke'
New-Item -ItemType Directory -Path $output -Force | Out-Null
$boot = Join-Path $output 'boot.dsk'
if (Test-Path -LiteralPath $boot) { Remove-Item -LiteralPath $boot }
$autoexec = Join-Path $output 'AUTOEXEC.BAT'
[IO.File]::WriteAllText($autoexec, "B:`r`nBLOODSTR`r`n", [Text.Encoding]::ASCII)
$sector = Join-Path $output 'bootsector.bin'
$template = [IO.File]::OpenRead((Resolve-Path -LiteralPath $BootTemplatePath).Path)
try {
    $bytes = New-Object byte[] 512
    if ($template.Read($bytes, 0, 512) -ne 512) { throw 'Template de boot incompleto.' }
    [IO.File]::WriteAllBytes($sector, $bytes)
}
finally { $template.Dispose() }
$diskTool = Join-Path $root 'tools\local\msxdisk.exe'
& $diskTool create $boot $sector
if ($LASTEXITCODE -ne 0) { throw 'Falha ao criar disco privado de teste.' }
& $diskTool add $boot (Join-Path $dos 'MSXDOS2.SYS') (Join-Path $dos 'COMMAND2.COM') $autoexec
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar DOS 2 privado de teste.' }
$previousOutput = $env:BLOODSTRAIN_SMOKE_OUTPUT
$previousPackage = $env:BLOODSTRAIN_SMOKE_PACKAGE
$previousPalette = $env:BLOODSTRAIN_SMOKE_PALETTE
$previousArt = $env:BLOODSTRAIN_SMOKE_ART
$previousMap = $env:BLOODSTRAIN_SMOKE_MAP
$previousAudio = $env:BLOODSTRAIN_SMOKE_AUDIO
$previousMusic = $env:BLOODSTRAIN_SMOKE_MUSIC_SECONDS
$previousHz = $env:BLOODSTRAIN_SMOKE_VIDEO_HZ
$env:BLOODSTRAIN_SMOKE_OUTPUT = $output
$env:BLOODSTRAIN_SMOKE_PACKAGE = $package
$env:BLOODSTRAIN_SMOKE_PALETTE = Join-Path $root 'assets\art\export\INTRO.PAL'
$env:BLOODSTRAIN_SMOKE_ART = Join-Path $root 'assets\art\export'
$env:BLOODSTRAIN_SMOKE_MAP = Join-Path $root 'build\obj\bloodstr.map'
$audio = 1
if ($SoundExtensions -contains 'fmpac') { $audio += 2 }
if ($SoundExtensions -contains 'scc') { $audio += 4 }
$env:BLOODSTRAIN_SMOKE_AUDIO = "$audio"
$env:BLOODSTRAIN_SMOKE_MUSIC_SECONDS = "$MusicSeconds"
$env:BLOODSTRAIN_SMOKE_VIDEO_HZ = "$VideoHz"
$extensions = @()
if ($SoundExtensions.Count) { $extensions += @('-ext', 'slotexpander') }
foreach ($extension in $SoundExtensions) { $extensions += @('-ext', $extension) }
try {
    & $Emulator -machine $Machine @extensions -ext ram512k -ext msxdos2 `
        -diska $boot -diskb $disk -script (Join-Path $root 'tests\openmsx_smoke.tcl') | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Emulador terminou com codigo $LASTEXITCODE." }
    $result = Get-Content -LiteralPath (Join-Path $output 'result.txt') -Raw
    if (-not $result.StartsWith('PASS:')) { throw $result }
    Add-Type -AssemblyName System.Drawing
    foreach ($name in @('title') + @(1..6 | ForEach-Object { "intro$_" })) {
        $image = [Drawing.Bitmap]::FromFile((Join-Path $output "$name.png"))
        try {
            if ($image.Width -ne 320 -or $image.Height -ne 240) {
                throw "Captura $name nao tem as dimensoes esperadas (320x240 com bordas)."
            }
            $colors = New-Object 'System.Collections.Generic.HashSet[int]'
            for ($y = 20; $y -lt 170; $y++) {
                for ($x = 32; $x -lt 288; $x++) {
                    [void]$colors.Add($image.GetPixel($x, $y).ToArgb())
                }
            }
            if ($colors.Count -lt 8) {
                throw "Captura $name nao mostra as cores da ilustracao (apenas $($colors.Count))."
            }
        }
        finally { $image.Dispose() }
    }
    Write-Host $result
}
finally {
    $env:BLOODSTRAIN_SMOKE_OUTPUT = $previousOutput
    $env:BLOODSTRAIN_SMOKE_PACKAGE = $previousPackage
    $env:BLOODSTRAIN_SMOKE_PALETTE = $previousPalette
    $env:BLOODSTRAIN_SMOKE_ART = $previousArt
    $env:BLOODSTRAIN_SMOKE_MAP = $previousMap
    $env:BLOODSTRAIN_SMOKE_AUDIO = $previousAudio
    $env:BLOODSTRAIN_SMOKE_MUSIC_SECONDS = $previousMusic
    $env:BLOODSTRAIN_SMOKE_VIDEO_HZ = $previousHz
    # The private system disk must never become a distributable game asset.
    Remove-Item -LiteralPath $boot
    Remove-Item -LiteralPath $autoexec
    Remove-Item -LiteralPath $sector
}
