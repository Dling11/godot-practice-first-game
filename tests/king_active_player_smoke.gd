extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const KingFrames = preload("res://assets/characters/playable/king/simple_reboot/king_simple_sprite_frames.tres")
const KingSword = preload("res://data/weapons/king_signature_sword.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	await process_frame
	var body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	var weapon_sprite := player.get_node("VisualRoot/WeaponVisual/Weapon") as Sprite2D
	if player.character_id != &"king" or body.sprite_frames != KingFrames:
		_fail("King is not the temporary active player presentation.")
		return
	if (
		player.attack_component.weapon != KingSword
		or player.weapon_visual.weapon != KingSword
		or player.get_equipped_weapon_item() == null
		or player.get_equipped_weapon_item().item_id != KingSword.weapon_id
	):
		_fail("King is still loading an Opaw weapon instead of his signature sword.")
		return
	if weapon_sprite.visible:
		_fail("King's integrated sword is being duplicated by Opaw's detached weapon presentation.")
		return
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		_fail("King does not expose an honest four-slot development loadout.")
		return
	var equipped_skill_count := 0
	for slot: SkillSlotDefinition in player.skill_loadout.get_ordered_slots():
		if slot.is_equipped():
			equipped_skill_count += 1
	if (
		equipped_skill_count != 4
		or player.skill_loadout.get_slot(1).ability.ability_id != &"echoing_sever"
		or player.skill_loadout.get_slot(2).ability.ability_id != &"riftbreak"
		or player.skill_loadout.get_slot(3).ability.ability_id != &"sovereign_pursuit"
		or player.skill_loadout.get_slot(4).ability.ability_id != &"king_skill_4"
	):
		_fail("King's loadout must expose all four implemented skill proofs.")
		return

	player._set_facing_direction(Vector2.RIGHT)
	player.movement_changed.emit(Vector2.RIGHT, true)
	if body.animation != &"walk_right" or body.sprite_frames.get_frame_count(&"walk_right") != 4:
		_fail("King did not enter his four-frame right walk.")
		return
	player.movement_changed.emit(Vector2.ZERO, false)
	var idle_body_position := body.position
	if not player.request_primary_attack() or body.animation != &"attack_right":
		_fail("King's basic attack did not enter the authored right-facing slash.")
		return
	for frame_index in range(24):
		await physics_frame
		if player.attack_component.phase == MeleeAttackComponent.Phase.ACTIVE:
			break
	if player.attack_component.phase != MeleeAttackComponent.Phase.ACTIVE or body.frame < 2 or body.frame > 3:
		_fail("King's active contact phase does not use its two-frame slash contact beat.")
		return
	if body.position != idle_body_position:
		_fail("King's body pivot shifts between idle and the attack contact phase.")
		return
	var observed_second_contact_pose := body.frame == 3
	for frame_index in range(4):
		await physics_frame
		observed_second_contact_pose = observed_second_contact_pose or body.frame == 3
		if player.attack_component.phase != MeleeAttackComponent.Phase.ACTIVE:
			break
	if not observed_second_contact_pose:
		_fail("King's second contact pose never receives visible screen time.")
		return
	player.attack_component.cancel_attack()
	if not player.request_evade(Vector2.LEFT) or body.animation != &"dash_left":
		_fail("King's safe locomotion-derived dash presentation is unavailable.")
		return
	player.evade_component.cancel_evade()
	if not player.request_ability(1) or not player.directional_wedge_targeting.is_targeting():
		_fail("King's implemented Skill 1 did not enter its explicit targeting state.")
		return
	if player.ability_1_component.is_casting():
		_fail("Echoing Sever cast before the player confirmed its preview.")
		return
	player.directional_wedge_targeting.cancel_targeting()
	if not player.request_ability(2) or not player.ability_2_component.is_casting():
		_fail("King's implemented Skill 2 did not begin its self-area cast.")
		return
	player.ability_2_component.cancel_cast()
	if not player.request_ability(4) or not player.ground_point_targeting.is_targeting():
		_fail("King's implemented Skill 4 did not enter its ground-targeting state.")
		return
	player.ground_point_targeting.cancel_targeting()
	print("King temporary active-player smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
