extends "res://tools/launch_king_axe_grip_review.gd"

## Owner-facing V3 fixture. Same real contact authority, isolated storage/actors.
const EXPANDED_POSES = preload("res://assets/characters/playable/king/axe_proof_v3/side.tres")
const CARRY_POSES = preload("res://assets/characters/playable/king/axe_proof_v3/carry.tres")
const EXPANDED_SWING = preload("res://assets/characters/playable/king/axe_proof_v3/swing.png")
const NAMES := ["Side sweep","Rising cut","Down cut","Hop slam","Whirlwind"]
const CUT_SOUNDS := [preload("res://assets/audio/sfx/player/greatsword/cut.wav"),preload("res://assets/audio/sfx/player/greatsword/return.wav"),preload("res://assets/audio/sfx/player/greatsword/cleave.wav")]
var _cut_audio: AudioStreamPlayer2D
var extra_targets: Array[Node2D] = []

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Iron Beard V3 HUGE / CARRY / SPIN (NO SAVES / REWARDS)"
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	var weapon := attack.weapon.duplicate(true) as WeaponDefinition
	var fan := ConvexPolygonShape2D.new()
	fan.points = PackedVector2Array([Vector2(2,-14),Vector2(20,-40),Vector2(56,-34),Vector2(72,0),Vector2(56,34),Vector2(20,40),Vector2(2,14)])
	var sweep := ConvexPolygonShape2D.new()
	sweep.points = PackedVector2Array([Vector2(-12,-36),Vector2(30,-54),Vector2(64,-42),Vector2(72,0),Vector2(64,42),Vector2(30,54),Vector2(-12,36)])
	var spin := CircleShape2D.new()
	spin.radius = 68
	weapon.weapon_id = &"review_iron_beard_axe_v3"
	weapon.melee_hitbox_shape = fan
	weapon.combo.animation_keys = PackedStringArray(["attack","return_cut","attack","heavy_cleave","return_cut"])
	weapon.combo.windups = PackedFloat32Array([0.20,0.20,0.24,0.36,0.30])
	weapon.combo.contacts = PackedFloat32Array([0.18,0.16,0.18,0.20,0.32])
	weapon.combo.recoveries = PackedFloat32Array([0.20,0.20,0.22,0.28,0.36])
	weapon.combo.damage_multipliers = PackedFloat32Array([1.0,1.10,1.15,1.50,1.35])
	weapon.combo.knockback_multipliers = PackedFloat32Array([1.0,1.1,1.3,1.8,1.5])
	weapon.combo.hitbox_shapes = [sweep,fan,fan,fan,spin]
	weapon.combo.radial_steps = PackedByteArray([0,0,0,0,1])
	assert(actor.set_weapon_definition(weapon))
	# The old sword's three-element audio/trail observer is not a five-cut rig.
	var effects := actor.get_node("GreatswordEffects")
	if attack.phase_changed.is_connected(effects._on_attack_phase): attack.phase_changed.disconnect(effects._on_attack_phase)
	axe_presenter.get_parent().remove_child(axe_presenter)
	axe_presenter.queue_free()
	swing_trail.get_parent().remove_child(swing_trail)
	swing_trail.queue_free()
	axe_presenter = Presenter.new()
	assert(axe_presenter.configure(EXPANDED_POSES,attack))
	assert(axe_presenter.configure_idle(CARRY_POSES))
	axe_presenter.position = Vector2(0,-16)
	axe_presenter.scale = Vector2(0.5,0.5)
	actor.get_node("VisualRoot").add_child(axe_presenter)
	swing_trail = SwingTrail.new()
	configure_trail(swing_trail)
	actor.add_child(swing_trail)
	_cut_audio = AudioStreamPlayer2D.new()
	_cut_audio.bus = &"SFX"
	_cut_audio.volume_db = -12
	actor.add_child(_cut_audio)
	var column: VBoxContainer = toolbar.get_child(0)
	for child in column.get_children():
		column.remove_child(child)
		child.queue_free()
	var label := Label.new()
	label.text = "IRON BEARD V3 · 72px REACH\nSPACE / click: next cut (one buffered)\nSweep → rise → chop → hop → spin\nLow carry; back rest after 4 seconds\nStationary pose review · NO SAVES"
	label.add_theme_font_size_override("font_size",10)
	column.add_child(label)
	_status = Label.new()
	_status.text = "Relaxed carry · contacts: 0"
	_status.add_theme_font_size_override("font_size",10)
	column.add_child(_status)
	_button(column,"Next cut · SPACE",strike)
	_button(column,"Play five-move combo",play_combo)
	_button(column,"Try whirlwind alone",try_spin)
	_button(column,"Place distant target · 60px",place_target)
	_button(column,"Surround King with targets",place_ring)
	_button(column,"Spawn moving Rootling",spawn_rootling)
	_button(column,"Cancel / relaxed carry",cancel_combo)
	_button(column,"Pause / resume · ESC",toggle_pause)
	_button(column,"Reset review",reset_review)
	extra_targets.clear()
	place_target()

func configure_trail(trail: SwingTrail) -> void:
	trail.configure(stage.player.attack_component,EXPANDED_SWING)
	trail.rows = 5
	trail.origins = PackedVector2Array([Vector2(64,64),Vector2(64,85.333),Vector2(64,64),Vector2(64,64),Vector2(64,64)])
	trail.world_pixels_per_texel = 1.4
	trail.world_origin = Vector2(0,-16)
	trail.edge_feather_pixels = 3.0

func play_combo() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or not _continuation.is_stopped(): return
	stage.player.attack_component.reset_combo()
	_auto_cuts_left = 4
	strike()

func try_spin() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	_continuation.stop()
	_auto_cuts_left = 0
	_queued_cut = false
	stage.player.attack_component._next_combo_step = 4
	strike()

func place_target() -> void:
	if paused: return
	if is_instance_valid(contact_target):
		contact_target.get_parent().remove_child(contact_target)
		contact_target.queue_free()
	contact_target = make_target(Vector2(60,0))

func make_target(offset: Vector2) -> Node2D:
	var target: Node2D = TARGET.instantiate()
	target.position = stage.player.global_position+offset
	stage.get_node("World/Actors").add_child(target)
	var health: HealthComponent = target.get_node("HealthComponent")
	health.set_maximum_health(10000,false)
	health.set_current_health(10000)
	return target

func place_ring() -> void:
	if paused: return
	for target in extra_targets:
		if is_instance_valid(target):
			target.get_parent().remove_child(target)
			target.queue_free()
	extra_targets.clear()
	for offset in [Vector2(-55,0),Vector2(-35,-42),Vector2(15,-52),Vector2(42,36),Vector2(-35,36)]:
		extra_targets.append(make_target(offset))

func _phase(phase: int,_duration: float) -> void:
	_status.text = "%s · %s · contacts: %d" % [NAMES[stage.player.attack_component.combo_step],["Carry","Wind-up","Contact","Recovery"][phase],_contacts]
	if phase==MeleeAttackComponent.Phase.ACTIVE and is_instance_valid(_cut_audio) and DisplayServer.get_name()!="headless":
		_cut_audio.stream = CUT_SOUNDS[[0,1,0,2,2][stage.player.attack_component.combo_step]]
		_cut_audio.pitch_scale = 0.85 if stage.player.attack_component.combo_step==4 else 1.0
		_cut_audio.play()

func _finished() -> void:
	_status.text = "Relaxed carry · contacts: %d" % _contacts
	if _auto_cuts_left>0 or _queued_cut:
		if _auto_cuts_left>0: _auto_cuts_left -= 1
		_queued_cut = false
		_continuation.start()
