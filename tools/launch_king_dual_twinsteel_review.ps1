param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--rendering-method', 'gl_compatibility', '--resolution', '1280x720', '--script', 'res://tools/launch_king_dual_twinsteel_review.gd')
# This is the owner-requested visible, interactive review window.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -PassThru | Select-Object Id,ProcessName
