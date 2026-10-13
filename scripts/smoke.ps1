# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$PackagePath,
    [Parameter(Mandatory = $true)][string]$DosFilesPath,
    [Parameter(Mandatory = $true)][string]$BootTemplatePath,
    [string]$Emulator = 'openmsx',
    [string]$Machine = 'Philips_NMS_8255'
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
$env:BLOODSTRAIN_SMOKE_OUTPUT = $output
try {
    & $Emulator -machine $Machine -ext ram512k -ext msxdos2 `
        -diska $boot -diskb $disk -script (Join-Path $root 'tests\openmsx_smoke.tcl') | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Emulador terminou com codigo $LASTEXITCODE." }
    $result = Get-Content -LiteralPath (Join-Path $output 'result.txt') -Raw
    if (-not $result.StartsWith('PASS:')) { throw $result }
    Add-Type -AssemblyName System.Drawing
    $image = [Drawing.Bitmap]::FromFile((Join-Path $output 'title.png'))
    try {
        if ($image.Width -ne 320 -or $image.Height -ne 240) {
            throw 'Captura raw nao tem as dimensoes esperadas (320x240 com bordas).'
        }
        $top = $image.GetPixel(40, 20)
        $bottom = $image.GetPixel(40, 180)
        if ($top.R -le 100 -or $top.G -ge 80 -or $top.B -ge 80 -or
            $bottom.B -le 100 -or $bottom.R -ge 80 -or $bottom.G -ge 80) {
            throw 'A captura PNG nao mostra as faixas vermelha e azul esperadas.'
        }
    }
    finally { $image.Dispose() }
    Write-Host $result
}
finally {
    $env:BLOODSTRAIN_SMOKE_OUTPUT = $previousOutput
    # The private system disk must never become a distributable game asset.
    Remove-Item -LiteralPath $boot
    Remove-Item -LiteralPath $autoexec
    Remove-Item -LiteralPath $sector
}
