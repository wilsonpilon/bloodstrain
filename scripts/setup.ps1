# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$directories = @(
    'src\core', 'src\world', 'src\actors', 'src\systems', 'src\audio', 'src\ui',
    'include\ui', 'assets\art\source', 'assets\art\export',
    'assets\audio\music', 'assets\audio\sfx', 'assets\audio\export',
    'data\maps', 'data\dialogues', 'data\items', 'data\classes', 'data\pets',
    'data\factions', 'docs\story', 'docs\screenshots', 'tests',
    'build\obj', 'build\generated', 'dist', 'tools\local'
)
foreach ($directory in $directories) {
    New-Item -ItemType Directory -Path (Join-Path $root $directory) -Force | Out-Null
}

$diskTool = Join-Path $root 'tools\local\msxdisk.exe'
if (-not (Test-Path -LiteralPath $diskTool)) {
    $archive = Join-Path $root 'msxDiskUtil\msxDiskUtil_1.8b.zip'
    if (-not (Test-Path -LiteralPath $archive)) {
        throw "msxDiskUtil ausente. Restaure msxDiskUtil na raiz ou instale tools\local\msxdisk.exe."
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($archive)
    try {
        $entry = $zip.GetEntry('msxdisk.exe')
        if ($null -eq $entry) { throw 'O ZIP do msxDiskUtil nao contem msxdisk.exe.' }
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $diskTool, $false)
    }
    finally { $zip.Dispose() }
}

foreach ($tool in @(
    'MSXgl\tools\build\Node\node.exe',
    'MSXgl\tools\sdcc\bin\sdcc.exe',
    'MSXgl\tools\MSXtk\bin\MSXhex.exe',
    'MSXgl\engine\script\js\build.js',
    'MSXgl\projects\template_msx2\msxgl_config.h'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $tool))) {
        throw "Dependencia ausente: $tool. Restaure a distribuicao completa da MSXgl."
    }
}
Write-Host 'Estrutura e ferramentas prontas.'
