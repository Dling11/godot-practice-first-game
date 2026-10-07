extends "res://tools/launch_king_axe_grip_review.gd"

## Reuses isolated input/encounter fixture; new weapon, art and physical steps.
const GREAT_POSES = preload("res://assets/characters/playable/king/huge_greatsword_proof/sweep.tres")
const GREAT_SWING = preload("res://assets/characters/playable/king/huge_greatsword_proof/swing.png")
const IMPACT_ART = preload("res://assets/characters/playable/king/huge_greatsword_proof/impact.png")
const StepMotion = preload("res://gameplay/movement/melee_step_motion.gd")
const ImpactPresenter = preload("res://gameplay/presentation/weapon_impact_presenter.gd")
const NAMES := ["Stepping sweep","Rising cut","Meteor slam","Turning cleave"]
var move_names := PackedStringArray(NAMES)
var move_sounds := PackedInt32Array([0,1,2,2])
const SOUNDS := [preload("res://assets/audio/sfx/player/greatsword/cut.wav"),preload("res://assets/audio/sfx/player/greatsword/return.wav"),preload("res://assets/audio/sfx/player/greatsword/cleave.wav")]
var step_motion: StepMotion
var impact_presenter: ImpactPresenter
var _cut_audio: AudioStreamPlayer2D
var extra_targets: Array[Node2D] = []

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_huge_greatsword_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Huge Greatsword / BODY / METEOR (NO SAVES / REWARDS)"
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	# Let local raster impacts carry weight without a global pause timer.
	var feedback := CombatFeedbackPresenter.find_for_player(actor)
	if feedback!=null: feedback.hitstop_enabled = false
	var weapon := attack.weapon.duplicate(true) as WeaponDefinition
	var broad := ConvexPolygonShape2D.new()
	broad.points = PackedVector2Array([Vector2(2,-20),Vector2(28,-58),Vector2(90,-52),Vector2(104,0),Vector2(90,52),Vector2(28,58),Vector2(2,20)])
	var rising := ConvexPolygonShape2D.new()
	rising.points = PackedVector2Array([Vector2(2,-14),Vector2(28,-48),Vector2(78,-42),Vector2(96,0),Vector2(78,42),Vector2(28,48),Vector2(2,14)])
	var slam := ConvexPolygonShape2D.new()
	slam.points = PackedVector2Array([Vector2(2,-18),Vector2(28,-42),Vector2(68,-36),Vector2(96,0),Vector2(68,36),Vector2(28,42),Vector2(2,18)])
	weapon.weapon_id = &"review_huge_greatsword"
	weapon.display_name = "Huge steel greatsword · movement proof"
	weapon.melee_hitbox_shape = broad
	weapon.combo.animation_keys = PackedStringArray(["attack","return_cut","heavy_cleave","attack"])
	weapon.combo.windups = PackedFloat32Array([0.30,0.28,0.64,0.36])
	weapon.combo.contacts = PackedFloat32Array([0.20,0.18,0.24,0.22])
	weapon.combo.recoveries = PackedFloat32Array([0.28,0.26,0.40,0.34])
	weapon.combo.damage_multipliers = PackedFloat32Array([1.10,1.20,1.85,1.45])
	weapon.combo.knockback_multipliers = PackedFloat32Array([1.25,1.4,2.4,1.8])
	weapon.combo.continue_seconds = 1.05
	weapon.combo.hitbox_shapes = [broad,rising,slam,broad]
	assert(actor.set_weapon_definition(weapon))
	var old_effects := actor.get_node("GreatswordEffects")
	if attack.phase_changed.is_connected(old_effects._on_attack_phase): attack.phase_changed.disconnect(old_effects._on_attack_phase)
	axe_presenter.get_parent().remove_child(axe_presenter)
	axe_presenter.queue_free()
	swing_trail.get_parent().remove_child(swing_trail)
	swing_trail.queue_free()
	step_motion = StepMotion.new()
	step_motion.actor = actor
	step_motion.attack = attack
	actor.add_child(step_motion)
	axe_presenter = Presenter.new()
	assert(axe_presenter.configure(GREAT_POSES,attack))
	axe_presenter.position = Vector2(0,-16)
	axe_presenter.scale = Vector2.ONE*0.5
	actor.get_node("VisualRoot").add_child(axe_presenter)
	swing_trail = SwingTrail.new()
	configure_trail(swing_trail)
	actor.add_child(swing_trail)
	impact_presenter = ImpactPresenter.new()
	impact_presenter.attack = attack
	impact_presenter.atlas = IMPACT_ART
	actor.add_child(impact_presenter)
	_cut_audio = AudioStreamPlayer2D.new()
	_cut_audio.bus = &"SFX"
	_cut_audio.volume_db = -12
	actor.add_child(_cut_audio)
	var column: VBoxContainer = toolbar.get_child(0)
	for child in column.get_children():
		column.remove_child(child)
		child.queue_free()
	column.position = Vector2(12,110)
	var label := Label.new()
	label.text = "HUGE GREATSWORD · BODY / IMPACT\nSPACE / click: cut (one buffered)\nSweep → rise → meteor → turn\nReal collision-checked attack steps\nRight-facing review · NO SAVES"
	label.add_theme_font_size_override("font_size",10)
	column.add_child(label)
	_status = Label.new()
	_status.text = "Low guard · contacts: 0"
	_status.add_theme_font_size_override("font_size",10)
	column.add_child(_status)
	_button(column,"Next cut · SPACE",strike)
	_button(column,"Play four-move combo",play_combo)
	_button(column,"Try meteor slam",try_slam)
	_button(column,"Place distant target · 88px",place_target)
	_button(column,"Place three-target front",place_crowd)
	_button(column,"Spawn moving Rootling",spawn_rootling)
	_button(column,"Cancel / low guard",cancel_combo)
	_button(column,"Pause / resume · ESC",toggle_pause)
	_button(column,"Reset review",reset_review)
	extra_targets.clear()
	place_target()

func configure_trail(trail: SwingTrail) -> void:
	trail.configure(stage.player.attack_component,GREAT_SWING)
	trail.rows = 4
	trail.origins = PackedVector2Array([Vector2(128,128),Vector2(128,128),Vector2(128,128),Vector2(128,128)])
	trail.world_pixels_per_texel = 1.0
	trail.world_origin = Vector2(0,-16)
	trail.edge_feather_pixels = 3

func play_combo() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or not _continuation.is_stopped(): return
	stage.player.attack_component.reset_combo()
	_auto_cuts_left = 3
	strike()

func try_slam() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	_continuation.stop()
	_auto_cuts_left = 0
	_queued_cut = false
	stage.player.attack_component._next_combo_step = 2
	strike()

func place_target() -> void:
	if paused: return
	if is_instance_valid(contact_target):
		contact_target.get_parent().remove_child(contact_target)
		contact_target.queue_free()
	contact_target = make_target(Vector2(88,0))

func make_target(offset: Vector2) -> Node2D:
	var target: Node2D = TARGET.instantiate()
	target.position = stage.player.global_position+offset
	stage.get_node("World/Actors").add_child(target)
	var health: HealthComponent = target.get_node("HealthComponent")
	health.set_maximum_health(10000,false)
	health.set_current_health(10000)
	return target

func place_crowd() -> void:
	if paused: return
	for target in extra_targets:
		if is_instance_valid(target):
			target.get_parent().remove_child(target)
			target.queue_free()
	extra_targets.clear()
	for offset in [Vector2(72,-24),Vector2(72,24)]: extra_targets.append(make_target(offset))

func _phase(phase: int,_duration: float) -> void:
	_status.text = "%s · %s · hits: %d" % [move_names[stage.player.attack_component.combo_step],["Guard","Wind-up","Contact","Recovery"][phase],_contacts]
	if phase==MeleeAttackComponent.Phase.ACTIVE and is_instance_valid(_cut_audio) and DisplayServer.get_name()!="headless":
		_cut_audio.stream = SOUNDS[move_sounds[stage.player.attack_component.combo_step]]
		_cut_audio.pitch_scale = 0.78 if stage.player.attack_component.combo_step==2 else 0.88
		_cut_audio.play()

func _finished() -> void:
	_status.text = "Low guard · contacts: %d" % _contacts
	if _auto_cuts_left>0 or _queued_cut:
		if _auto_cuts_left>0: _auto_cuts_left -= 1
		_queued_cut = false
		_continuation.start()
