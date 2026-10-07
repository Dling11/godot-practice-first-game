param([string]$GodotPath='D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe',[switch]$Scythe)
$ErrorActionPreference='Stop'
$projectPath=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$arguments=@('--path',('"'+$projectPath+'"'),'--rendering-method','gl_compatibility','--script','res://tools/review_king_heavy_burst.gd')
if($Scythe) { $arguments+=@('--','--scythe') }
Start-Process -FilePath $GodotPath -ArgumentList $arguments
