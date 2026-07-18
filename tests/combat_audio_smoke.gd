extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const ThrallScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")
const SpitterScene = preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn")
const ImpactScene = preload("res://gameplay/projectiles/bramble_seed_impact.tscn")
const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	if AudioServer.get_bus_index("Music") < 0 or AudioServer.get_bus_index("SFX") < 0 or AudioServer.get_bus_index("UI") < 0:
		_fail("AudioDirector did not create the Music, SFX, and UI buses.")
		return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	var player_sfx := player.get_node("PlayerActionSfx") as PlayerActionSfx
	if (
		not _valid_sfx_player(player_sfx.sword_swing_player)
		or not _valid_sfx_player(player_sfx.ability_player)
		or not _valid_sfx_player(player_sfx.dash_player)
		or not _valid_sfx_player(player_sfx.piercing_charge_player)
		or not _valid_sfx_player(player_sfx.piercing_thrust_player)
		or player_sfx.piercing_thrust_player.stream == player_sfx.sword_swing_player.stream
	):
		_fail("Player action and dedicated Piercing Rush SFX are not fully assigned to the SFX bus.")
		return

	var thrall := ThrallScene.instantiate() as ForsakenThrall
	var mireling := MirelingScene.instantiate() as Mireling
	var spitter := SpitterScene.instantiate() as BrambleSpitter
	for enemy in [thrall, mireling, spitter]:
		root.add_child(enemy)
	var thrall_sfx := thrall.get_node("ActionSfx") as ActorActionSfx
	var mireling_sfx := mireling.get_node("ActionSfx") as ActorActionSfx
	var spitter_sfx := spitter.get_node("ActionSfx") as ActorActionSfx
	if not _valid_sfx_player(thrall_sfx.primary_player) or thrall_sfx.primary_state != ForsakenThrall.State.ACTIVE:
		_fail("Thrall claw SFX is not synchronized with its active attack state.")
		return
	if not _valid_sfx_player(mireling_sfx.primary_player) or not _valid_sfx_player(mireling_sfx.secondary_player):
		_fail("Mireling leap and landing SFX are not configured.")
		return
	if mireling_sfx.primary_state != Mireling.State.LEAP or mireling_sfx.secondary_state != Mireling.State.ACTIVE:
		_fail("Mireling SFX states do not match leap and landing authority.")
		return
	if not _valid_sfx_player(spitter_sfx.primary_player):
		_fail("Bramble Spitter firing SFX is not configured.")
		return

	var impact := ImpactScene.instantiate()
	root.add_child(impact)
	var impact_player := impact.get_node("ImpactSfx") as AudioStreamPlayer2D
	if not _valid_sfx_player(impact_player):
		_fail("Bramble seed impact SFX is not configured.")
		return
	var arena := ArenaScene.instantiate()
	var feedback := arena.get_node("GameplayServices/CombatFeedback") as CombatFeedbackPresenter
	if feedback.sword_hit_sound == null or feedback.ability_hit_sound == null or feedback.player_hurt_sound == null:
		_fail("Accepted-hit, Piercing Rush impact, and player-damage SFX are not configured in the arena.")
		return
	arena.free()
	print("Combat audio smoke test passed.")
	quit(0)


func _valid_sfx_player(player: AudioStreamPlayer2D) -> bool:
	return player != null and player.stream != null and player.bus == &"SFX"


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
