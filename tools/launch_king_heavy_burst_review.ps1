param([string]$GodotPath='D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$ErrorActionPreference='Stop'
# Preserve the owner's existing shortcut, now opening actual playable V2.
& (Join-Path $PSScriptRoot 'launch_king_greatsword_v2_training.ps1') -GodotPath $GodotPath
