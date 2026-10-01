$ErrorActionPreference = 'Stop'
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$utf8 = [Text.UTF8Encoding]::new($false)
function Read-Project([string]$relative) { [IO.File]::ReadAllText((Join-Path $workspaceRoot $relative)) }
function Write-Project([string]$relative, [string]$content) { [IO.File]::WriteAllText((Join-Path $workspaceRoot $relative), $content, $utf8) }
function Move-Project([string]$from, [string]$to) {
    $source = [IO.Path]::GetFullPath((Join-Path $workspaceRoot $from))
    $destination = [IO.Path]::GetFullPath((Join-Path $workspaceRoot $to))
    foreach ($target in @($source,$destination)) {
        if (-not $target.StartsWith($workspaceRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw "Outside workspace: $target" }
    }
    if (Test-Path -LiteralPath $destination) { throw "Destination exists: $destination" }
    New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
    Move-Item -LiteralPath $source -Destination $destination
    foreach ($suffix in @('.uid','.import')) {
        if (Test-Path -LiteralPath ($source+$suffix)) { Move-Item -LiteralPath ($source+$suffix) -Destination ($destination+$suffix) }
    }
}
$renames = [ordered]@{
 'refuge_study.gd'='sanctuary_town.gd'
 'refuge_ground.gd'='town_ground.gd'
 'orren_workshop_review.gd'='orren_workshop.gd'
 'eira_renewal_review.gd'='eira_presentation.gd'
 'artisan_renewal_review.gd'='artisan_presentation.gd'
 'sanctuary_ui_review.gd'='sanctuary_interface.gd'
 'town_dressing.gd'='town_dressing.gd'
 'town_map.gd'='town_map.gd'
 'town_map_drawing.gd'='town_map_drawing.gd'
 'town_noticeboard.gd'='town_noticeboard.gd'
 'garden_birds.gd'='garden_birds.gd'
 'foliage_wind.gdshader'='foliage_wind.gdshader'
 'workshop_visit.gd'='workshop_visit.gd'
 'workshop_interior.gd'='workshop_interior.gd'
}
foreach ($entry in $renames.GetEnumerator()) { Move-Project ('levels/sanctuary/review/'+$entry.Key) ('levels/sanctuary/town/'+$entry.Value) }
$activeFiles = & rg --files levels entities environment gameplay ui tools tests data assets -g '*.gd' -g '*.gdshader' -g '*.tscn' -g '*.tres' -g '*.ps1'
foreach ($file in $activeFiles) {
    $text = Read-Project $file
    $before = $text
    foreach ($entry in $renames.GetEnumerator()) { $text = $text.Replace(('res://levels/sanctuary/review/'+$entry.Key), ('res://levels/sanctuary/town/'+$entry.Value)) }
    if ($text -ne $before) { Write-Project $file $text }
}
# Real NPC scenes load the accepted frames directly. Retired idle timers/aura are removed.
foreach ($recipe in @(
 @('entities/npcs/armskeeper/armskeeper.tscn','armskeeper','idle_down','LanternAura'),
 @('entities/npcs/skillkeeper/skillkeeper.tscn','skillkeeper','idle_down','IdleAura'),
 @('entities/npcs/rootweaver/rootweaver_nema.tscn','rootweaver','artisan_work',''),
 @('entities/npcs/umi/umi.tscn','umi','artisan_work','')
)) {
    $path,$identity,$animation,$aura = $recipe
    $text = Read-Project $path
    if ($identity -in @('armskeeper','skillkeeper')) {
        $text = [regex]::Replace($text,'(?m)^\[ext_resource type="Texture2D"[^\r\n]*id="2_sheet"\]\r?\n','[ext_resource type="SpriteFrames" path="res://assets/characters/npcs/'+$identity+'/renewal/sprite_frames.tres" id="2_frames"]' + "`n" + '[ext_resource type="Texture2D" path="res://assets/characters/npcs/'+$identity+'/renewal/portrait.png" id="3_portrait"]' + "`n")
        $text = [regex]::Replace($text,'(?ms)^\[sub_resource type="AtlasTexture" id="Frame1"\].*?(?=^\[sub_resource type="CircleShape2D")','')
        $text = $text.Replace('sprite_frames = SubResource("IdleFrames")','sprite_frames = ExtResource("2_frames")')
        $text = [regex]::Replace($text,'(?m)^\[ext_resource type="Script"[^\r\n]*id="4_breath"\]\r?\n','')
        $text = [regex]::Replace($text,'(?ms)^\[node name="IdleBreath"[^\r\n]*\].*?(?=^\[node |\z)','')
        $text = $text.Replace(' node_paths=PackedStringArray("idle_aura")','')
        $text = [regex]::Replace($text,'(?m)^idle_aura = [^\r\n]*\r?\n','')
        $text = [regex]::Replace($text,'(?ms)^\[node name="'+$aura+'"[^\r\n]*\].*?(?=^\[node name="Sprite")','')
        $text = $text.Replace('script = ExtResource("1_script")','script = ExtResource("1_script")' + "`n" + 'dialogue_portrait = ExtResource("3_portrait")')
    } else {
        $text = [regex]::Replace($text,'(?m)^\[ext_resource type="SpriteFrames"[^\r\n]*id="2_frames"\]\r?\n','[ext_resource type="SpriteFrames" path="res://assets/characters/npcs/'+$identity+'/renewal/sprite_frames.tres" id="2_frames"]' + "`n")
        $text = [regex]::Replace($text,'(?m)^\[ext_resource type="Texture2D"[^\r\n]*id="3_portrait"\]\r?\n','[ext_resource type="Texture2D" path="res://assets/characters/npcs/'+$identity+'/renewal/portrait.png" id="3_portrait"]' + "`n")
        $text = [regex]::Replace($text,'(?m)^\[ext_resource type="Script"[^\r\n]*id="5_work"\]\r?\n','')
        $text = [regex]::Replace($text,'(?ms)^\[node name="WorkIdle"[^\r\n]*\].*?(?=^\[node |\z)','')
    }
    $text = [regex]::Replace($text,'(?ms)(^\[node name="Sprite"[^\r\n]*\]\r?\n).*?(?=^\[node |\z)', '$1' + 'position = Vector2(0, -16)' + "`n" + 'scale = Vector2(0.5, 0.5)' + "`n" + 'texture_filter = 1' + "`n" + 'sprite_frames = ExtResource("2_frames")' + "`n" + 'animation = &"'+$animation+'"' + "`n" + 'autoplay = "'+$animation+'"' + "`n`n")
    $text = [regex]::Replace($text,'^\[gd_scene load_steps=\d+ format=3\]','[gd_scene format=3]')
    Write-Project $path $text
}
# Drop old ground/building/tree/cart instances from the canonical scene.
$scene = Read-Project 'levels/sanctuary/sanctuary.tscn'
foreach ($id in @('3_tileset','4_ground','5_dwelling','6_hall','7_stall','8_tree_broad','9_tree_tall','20_rootforge','24_crucible')) {
    $scene = [regex]::Replace($scene,'(?m)^\[ext_resource [^\r\n]*id="'+$id+'"\]\r?\n','')
}
foreach ($node in @('Ground','SkillkeeperLodge','ArmskeeperWorkshop','ArmskeeperCart','TreeNorthWest','TreeNorthEast','TreeWest','TreeEast','TreeSouthWest','TreeSouthEast','LivingRootforge','EchoCrucible')) {
    $scene = [regex]::Replace($scene,'(?ms)^\[node name="'+$node+'"[^\r\n]*\].*?(?=^\[node |\z)','')
}
$scene = $scene.Replace('SANCTUARY REVIEW · NO SAVES','SANCTUARY TEST · NO SAVES')
Write-Project 'levels/sanctuary/sanctuary.tscn' $scene
# Preserve test utility methods, separating them from retired comparison assertions.
$base = Read-Project 'tests/sanctuary_refuge_review_smoke.gd'
$base = "extends SceneTree`n`nconst HUB = preload(`"res://levels/sanctuary/sanctuary.tscn`")`nconst Study = preload(`"res://levels/sanctuary/town/sanctuary_town.gd`")`nvar failures := 0`nvar checks := 0`n`nfunc _initialize() -> void:`n`tcall_deferred(`"_run`")`n`nfunc _run() -> void:`n`tquit()`n`n" + $base.Substring($base.IndexOf('func _blocked('))
$base = [regex]::Replace($base,'(?s)func capture\(.*?(?=func check\()','')
Write-Project 'tests/sanctuary_test_base.gd' $base
$retired = @(
 'tests/sanctuary_refuge_review_smoke.gd','tests/sanctuary_life_smoke.gd','tests/sanctuary_courtyards_smoke.gd','tests/sanctuary_interface_smoke.gd','tests/sanctuary_hub_smoke.gd','tests/rootweaver_service_smoke.gd',
 'tools/capture_sanctuary_baseline.gd','tools/capture_rootweaver_service.gd','tools/process_sanctuary_direction_board.gd','tools/process_sanctuary_individual_assets.gd','tools/process_rootweaver_service_assets.gd',
 'levels/sanctuary/sanctuary_ground.gd','entities/npcs/rootweaver/rootweaver_work_idle.gd','entities/npcs/umi/umi_work_idle.gd',
 'environment/props/sanctuary/skillkeeper_lodge.tscn','environment/props/sanctuary/armskeeper_workshop.tscn','environment/props/sanctuary/armskeeper_cart.tscn','environment/props/sanctuary/sanctuary_tree_broad.tscn','environment/props/sanctuary/sanctuary_tree_tall.tscn',
 'environment/props/sanctuary/rootweaver_living_rootforge/rootweaver_living_rootforge.tscn','environment/props/sanctuary/echo_crucible/echo_crucible.tscn',
 'assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png','assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png','assets/characters/npcs/rootweaver/rootweaver_nema_sprite_frames.tres','assets/characters/npcs/rootweaver/rootweaver_nema_service_sheet_48x48.png','assets/characters/npcs/rootweaver/rootweaver_nema_portrait_96x96.png','assets/characters/npcs/umi/umi_sprite_frames.tres','assets/characters/npcs/umi/umi_side_service_sheet_48x48.png','assets/characters/npcs/umi/umi_dialogue_portrait_96x96.png',
 'assets/characters/npcs/armskeeper/renewal/idle_work.png','assets/characters/npcs/courier/walk.png',
 'assets/environment/sanctuary/buildings/armskeeper_workshop_176x192.png','assets/environment/sanctuary/buildings/skillkeeper_lodge_128x192.png','assets/environment/sanctuary/shops/armskeeper_cart_128x96.png','assets/environment/sanctuary/props/sanctuary_tree_broad_96x120.png','assets/environment/sanctuary/props/sanctuary_tree_tall_96x120.png','assets/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_176x144.png','assets/environment/sanctuary/services/umi/umi_echo_crucible_workbench_72x64.png',
 'assets/environment/sanctuary/tiles/sanctuary_ground_tileset.tres','assets/environment/sanctuary/tiles/sanctuary_ground_atlas_64x64.png','assets/environment/sanctuary/courtyards/nema_side.png','assets/environment/sanctuary/courtyards/umi_side.png','assets/environment/sanctuary/refuge_review/wall.png',
 'assets/environment/sanctuary/interiors/orren/shell.png','assets/environment/sanctuary/interiors/orren/workbench.png','assets/environment/sanctuary/interiors/orren/forge.png','assets/environment/sanctuary/interiors/orren/rack.png'
)
foreach ($file in $retired) { Move-Project $file ('art_source/archive/sanctuary_retired_2026_10_02/retired/'+$file) }
Write-Project 'art_source/archive/sanctuary_retired_2026_10_02/retired_paths.json' ($retired | ConvertTo-Json)
foreach ($file in @('tests/sanctuary_skills_flow_smoke.gd','tests/sanctuary_workshop_interior_smoke.gd')) {
    $text = (Read-Project $file).Replace('res://tests/sanctuary_refuge_review_smoke.gd','res://tests/sanctuary_test_base.gd')
    $text = [regex]::Replace($text,'\tvar study := Study.new\(\)\r?\n\tstudy.hub = hub\r?\n\thub.add_child\(study\)','\tvar study: Node = hub.get_node("SanctuaryTown")'.Replace('\t',"`t") + "`n`tstudy.enable_test_controls()")
    Write-Project $file $text
}
foreach ($file in @('tests/player_interface_readability_smoke.gd','tools/launch_sanctuary_study.gd')) {
    $text = Read-Project $file
    $text = [regex]::Replace($text,'\tvar study(?:: Node)? (?:= load\("res://levels/sanctuary/town/sanctuary_town.gd"\).new\(\)|:= Study.new\(\))\r?\n\tstudy.hub = hub\r?\n\thub.add_child\(study\)','\tvar study: Node = hub.get_node("SanctuaryTown")'.Replace('\t',"`t") + "`n`tstudy.enable_test_controls()")
    Write-Project $file $text
}
Write-Project 'tests/player_interface_demo_smoke.gd' ((Read-Project 'tests/player_interface_demo_smoke.gd').Replace('SanctuaryStudy','SanctuaryTown'))
Write-Output 'Runtime modules promoted, retired content archived, scenes and test consumers migrated.'
