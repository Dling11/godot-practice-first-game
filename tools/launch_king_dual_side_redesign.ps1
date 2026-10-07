param(
    [string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe',
    [string]$LogPath = ''
)
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--rendering-method', 'gl_compatibility', '--resolution', '1000x560', '--script', 'res://tools/review_king_dual_side_redesign.gd')
if ($LogPath) { $reviewArgs += @('--log-file', ('"' + $LogPath + '"')) }
# User-requested visible animation review; this study never grants equipment.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -PassThru | Select-Object Id,ProcessName
