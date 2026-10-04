param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--resolution', '1280x720', '--script', 'res://tools/launch_king_axe_expanded_review.gd')
# Visible owner-facing isolated motion test.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -PassThru | Select-Object Id,ProcessName
