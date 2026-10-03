param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--resolution', '960x540', '--script', 'res://tools/launch_campfire_title_preview.gd')
# This launcher is an interactive owner preview, so its game window is visible.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -WindowStyle Normal -PassThru | Select-Object Id, ProcessName
