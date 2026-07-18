extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const AshwoodBlade = preload("res://data/weapons/ashwood_blade.tres")
const BalancedSlash = preload("res://data/weapons/attack_styles/balanced_slash.tres")
const SwiftSlash = preload("res://data/weapons/attack_styles/swift_slash.tres")
const HeavyCleave = preload("res://data/weapons/attack_styles/heavy_cleave.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var styles: Array[SwordAttackStyleDefinition] = [BalancedSlash, SwiftSlash, HeavyCleave]
	var style_ids: Dictionary = {}
	for style in styles:
		if not style.is_valid_style():
			_fail("Sword style %s is invalid." % style.resource_path)
			return
		style_ids[style.style_id] = true
	if style_ids.size() != styles.size():
		_fail("Sword attack style IDs must be unique.")
		return
	if AshwoodBlade.attack_style != BalancedSlash:
		_fail("Ashwood Blade must use the Balanced Slash style.")
		return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	var body: AnimatedSprite2D = player.get_node("VisualRoot/Body")
	var shared_body_frames := body.sprite_frames
	if player.weapon_visual.position != Vector2(12.0, -8.0):
		_fail("The down-facing sword was not raised to its approved front-view anchor.")
		return
	if BalancedSlash.normal_variant_count() != 3:
		_fail("Balanced Slash must expose the approved three-swing visual sequence.")
		return
	var opening_rotations := player.weapon_visual._attack_rotations(
		&"right",
		BalancedSlash.normal_variant_wind_up_arc(0),
		BalancedSlash.normal_variant_strike_arc(0),
		BalancedSlash.normal_variant_direction(0)
	)
	var return_rotations := player.weapon_visual._attack_rotations(
		&"right",
		BalancedSlash.normal_variant_wind_up_arc(1),
		BalancedSlash.normal_variant_strike_arc(1),
		BalancedSlash.normal_variant_direction(1)
	)
	if (
		opening_rotations.x >= opening_rotations.y
		or return_rotations.x <= return_rotations.y
		or BalancedSlash.normal_variant_active_extension(2)
		<= BalancedSlash.normal_variant_active_extension(0)
	):
		_fail("The three-swing sequence lacks an opening, reverse return, or extended finish.")
		return
	var observed_variants: Array[int] = []
	for attack_index in 3:
		player.weapon_visual.play_attack_phase(MeleeAttackComponent.Phase.WIND_UP, 0.01)
		observed_variants.append(player.weapon_visual._normal_swing_variant_index)
		player.weapon_visual.resume_locomotion()
	if observed_variants != [0, 1, 2]:
		_fail("Normal attacks did not cycle through all three swing variants: %s" % [observed_variants])
		return

	var upgraded_weapon := AshwoodBlade.duplicate(true) as WeaponDefinition
	upgraded_weapon.weapon_id = &"test_upgraded_blade"
	upgraded_weapon.display_name = "Test Upgraded Blade"
	upgraded_weapon.damage = 40.0
	upgraded_weapon.world_visual_scale = 1.2
	upgraded_weapon.attack_style = BalancedSlash
	if not player.set_weapon_definition(upgraded_weapon):
		_fail("An idle higher-grade sword could not reuse Opaw's weapon rig.")
		return
	if (
		player.attack_component.weapon != upgraded_weapon
		or player.weapon_visual.weapon != upgraded_weapon
		or body.sprite_frames != shared_body_frames
	):
		_fail("Weapon swapping did not preserve one shared body animation and synchronized data.")
		return
	if not is_equal_approx(player.weapon_visual.weapon_sprite.scale.x, 1.2):
		_fail("Weapon-specific world scale was not applied during the swap.")
		return

	var swift_weapon := AshwoodBlade.duplicate(true) as WeaponDefinition
	swift_weapon.weapon_id = &"test_swift_blade"
	swift_weapon.attack_style = SwiftSlash
	var heavy_weapon := AshwoodBlade.duplicate(true) as WeaponDefinition
	heavy_weapon.weapon_id = &"test_heavy_blade"
	heavy_weapon.attack_style = HeavyCleave
	if not player.set_weapon_definition(swift_weapon):
		_fail("Swift Slash could not be selected through weapon data.")
		return
	var swift_anchor: Vector2 = player.weapon_visual._attack_anchor(
		&"right", MeleeAttackComponent.Phase.ACTIVE, false
	)
	if not player.set_weapon_definition(heavy_weapon):
		_fail("Heavy Cleave could not be selected through weapon data.")
		return
	var heavy_anchor: Vector2 = player.weapon_visual._attack_anchor(
		&"right", MeleeAttackComponent.Phase.ACTIVE, false
	)
	if heavy_anchor.x <= swift_anchor.x:
		_fail("Heavy Cleave does not visibly extend farther than Swift Slash.")
		return
	if (
		body.sprite_frames != shared_body_frames
		or not is_equal_approx(player.weapon_visual.swing_trail.width, HeavyCleave.trail_width)
		or player.weapon_visual.swing_trail.default_color != HeavyCleave.trail_color
	):
		_fail("Style swapping did not update presentation while preserving the body animation.")
		return

	if not player.request_primary_attack():
		_fail("Could not begin the attack needed to verify swap locking.")
		return
	if player.set_weapon_definition(swift_weapon):
		_fail("Weapon swapping must be rejected while an attack is active.")
		return
	player.attack_component.cancel_attack()
	print("Sword attack style smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
