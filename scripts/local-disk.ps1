# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param(
    [string]$PackagePath,
    [switch]$Test,
    [string]$Emulator = 'openmsx'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
if (-not $PackagePath) {
    $version = (Get-Content -LiteralPath (Join-Path $root 'version.json') -Raw |
        ConvertFrom-Json).version
    $PackagePath = Join-Path $root "dist\Bloodstrain-$version"
}
$package = (Resolve-Path -LiteralPath $PackagePath).Path
$metadata = Get-Content -LiteralPath (Join-Path $package 'version.json') -Raw | ConvertFrom-Json
$output = Join-Path $root 'temp'
$currentDisk = Join-Path $output 'bloodstrain-current.dsk'
$disk = Join-Path $output 'bloodstrain-current-staging.dsk'
$tool = Join-Path $root 'tools\local\msxdisk.exe'
$dos = Join-Path $root 'MSXgl\tools\build\DOS'
$files = @(
    (Join-Path $dos 'MSXDOS2.SYS'),
    (Join-Path $dos 'COMMAND2.COM'),
    (Join-Path $package 'BLOODSTR.COM'),
    (Join-Path $package 'INTRO.PAK')
)
foreach ($file in $files + @($tool, (Join-Path $root 'msxDiskUtil\msxdos.dsk'))) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Arquivo necessario ausente: $file"
    }
}
if (Test-Path -LiteralPath $disk) { throw "Staging de disco ja existe; inspecione antes de repetir: $disk" }
New-Item -ItemType Directory -Path $output -Force | Out-Null
$sector = Join-Path $output 'bootsector.bin'
$autoexec = Join-Path $output 'AUTOEXEC.BAT'
try {
    $template = [IO.File]::OpenRead((Join-Path $root 'msxDiskUtil\msxdos.dsk'))
    try {
        $bytes = New-Object byte[] 512
        if ($template.Read($bytes, 0, 512) -ne 512) { throw 'Setor de boot incompleto.' }
        [IO.File]::WriteAllBytes($sector, $bytes)
    }
    finally { $template.Dispose() }
    [IO.File]::WriteAllText($autoexec, "BLOODSTR`r`n", [Text.Encoding]::ASCII)
    & $tool create $disk $sector
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao criar disco local.' }
    & $tool add $disk @files $autoexec
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao adicionar DOS2 e jogo ao disco local.' }
    & $tool list $disk -l
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao listar disco local.' }
    if ((Get-Item -LiteralPath $disk).Length -ne 737280) { throw 'Tamanho de DSK incorreto.' }
    if ($Test) {
        $capture = Join-Path $output 'test'
        New-Item -ItemType Directory -Path $capture -Force | Out-Null
        $previousOutput = $env:BLOODSTRAIN_SMOKE_OUTPUT
        $previousPackage = $env:BLOODSTRAIN_SMOKE_PACKAGE
        $previousPalette = $env:BLOODSTRAIN_SMOKE_PALETTE
        $previousArt = $env:BLOODSTRAIN_SMOKE_ART
        $previousMap = $env:BLOODSTRAIN_SMOKE_MAP
        try {
            $env:BLOODSTRAIN_SMOKE_OUTPUT = $capture
            $env:BLOODSTRAIN_SMOKE_PACKAGE = $package
            $env:BLOODSTRAIN_SMOKE_PALETTE = Join-Path $root 'assets\art\export\INTRO.PAL'
            $env:BLOODSTRAIN_SMOKE_ART = Join-Path $root 'assets\art\export'
            $env:BLOODSTRAIN_SMOKE_MAP = Join-Path $root 'build\obj\bloodstr.map'
            & $Emulator -machine Philips_NMS_8255 -ext ram512k -ext msxdos2 `
                -diska $disk -script (Join-Path $root 'tests\openmsx_smoke.tcl') | Out-Host
            if ($LASTEXITCODE -ne 0) { throw 'Falha ao executar openMSX.' }
            $result = Get-Content -LiteralPath (Join-Path $capture 'result.txt') -Raw
            if (-not $result.StartsWith('PASS:')) { throw $result }
            Write-Host $result
        }
        finally {
            $env:BLOODSTRAIN_SMOKE_OUTPUT = $previousOutput
            $env:BLOODSTRAIN_SMOKE_PACKAGE = $previousPackage
            $env:BLOODSTRAIN_SMOKE_PALETTE = $previousPalette
            $env:BLOODSTRAIN_SMOKE_ART = $previousArt
            $env:BLOODSTRAIN_SMOKE_MAP = $previousMap
        }
    }
    Move-Item -LiteralPath $disk -Destination $currentDisk -Force
    Write-Host "Disco inicializavel local atualizado para $($metadata.version) (nao redistribuir DOS): $currentDisk"
}
finally {
    foreach ($file in @($sector, $autoexec, $disk)) {
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file }
    }
}
