extends Node

## Presentation adapter for existing service actors; service authority stays in SanctuaryFlow.
const Nameplate = preload("res://entities/npcs/presentation/npc_nameplate.gd")
var npc: DialogueNpc
var sprite: AnimatedSprite2D
var frames: SpriteFrames
var nameplate: Node2D
var _old: Dictionary
var _portrait: Texture2D
var _enabled := false
var _talking := false
var _attention: Timer
var _work_idle: Timer
var _strike: AudioStreamPlayer2D

func configure(hub: Node, node_name: String, asset_folder: String, display_name: String, role: String) -> void:
	npc = hub.get_node("World/Actors/"+node_name)
	sprite = npc.get_node("Sprite")
	_work_idle = npc.get_node("WorkIdle")
	_strike = npc.get_node_or_null("ForgeStrikeAudio")
	_old = {"frames":sprite.sprite_frames,"animation":sprite.animation,"position":sprite.position,
		"scale":sprite.scale,"portrait":npc.dialogue_portrait,"filter":sprite.texture_filter,
		"timer_running":not _work_idle.is_stopped()}
	var sheet: Texture2D = load("res://assets/characters/npcs/"+asset_folder+"/renewal/idle_work.png")
	_portrait = load("res://assets/characters/npcs/"+asset_folder+"/renewal/portrait.png")
	frames = SpriteFrames.new()
	frames.remove_animation(&"default")
	# Unique animation name keeps old work callbacks dormant while the adapter is enabled.
	frames.add_animation(&"artisan_work")
	frames.set_animation_speed(&"artisan_work",5)
	for index in 8:
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(index%4*96,index/4*96,96,96)
		frame.filter_clip = true
		frames.add_frame(&"artisan_work",frame,5.0 if index == 0 else (3.0 if index == 7 else 1.0))
	_attention = Timer.new()
	_attention.one_shot = true
	_attention.wait_time = 1.1
	_attention.timeout.connect(func() -> void:
		if _enabled and not _talking: sprite.play(&"artisan_work"))
	add_child(_attention)
	nameplate = Nameplate.new()
	nameplate.npc_name = display_name
	nameplate.role_name = role
	nameplate.position = Vector2(0,-64)
	npc.add_child(nameplate)
	npc.proximity_changed.connect(func(near: bool, _text: String, _icon: Texture2D) -> void: nameplate.set_near(near))
	npc.dialogue_requested.connect(func(_speaker: String, _lines: Array[String], _image: Texture2D) -> void:
		if _enabled:
			_talking = true
			_hold())
	hub.dialogue_panel.dialogue_closed.connect(func(_completed: bool) -> void:
		if _talking:
			_talking = false
			if _enabled: sprite.play(&"artisan_work"))
	sprite.frame_changed.connect(func() -> void:
		if _enabled and sprite.animation == &"artisan_work" and sprite.frame == 5 and _strike != null:
			_strike.play())

func set_enabled(value: bool) -> void:
	_enabled = value
	_attention.stop()
	_work_idle.stop()
	if _strike != null: _strike.stop()
	nameplate.visible = value
	sprite.sprite_frames = frames if value else _old.frames
	sprite.position = Vector2(0,-16) if value else _old.position
	sprite.scale = Vector2(.5,.5) if value else _old.scale
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if value else _old.filter
	npc.dialogue_portrait = _portrait if value else _old.portrait
	sprite.play(&"artisan_work" if value else _old.animation)
	if value and _talking: _hold()
	if not value and _old.timer_running: _work_idle.start()
	nameplate.set_near(npc._player_inside)

func greet() -> void:
	if not _enabled or _talking: return
	_hold()
	_attention.start()

func _hold() -> void:
	sprite.pause()
	sprite.frame = 0
