extends Node

## Review-only presentation; DialogueNpc and SanctuaryFlow retain skill-service authority.
const IDLE = preload("res://assets/characters/npcs/skillkeeper/renewal/idle_read.png")
const PORTRAIT = preload("res://assets/characters/npcs/skillkeeper/renewal/portrait.png")
const Nameplate = preload("res://entities/npcs/presentation/npc_nameplate.gd")
const EIRA_POSITION := Vector2(384, 410)
const APPROACH := EIRA_POSITION + Vector2(0, 36)

var npc: DialogueNpc
var sprite: AnimatedSprite2D
var frames: SpriteFrames
var nameplate: Node2D
var _old: Dictionary
var _enabled := false
var _talking := false
var _attention_timer: Timer

func configure(hub: Node) -> void:
	npc = hub.get_node("World/Actors/Skillkeeper")
	sprite = npc.get_node("Sprite")
	var breath: Timer = npc.get_node("IdleBreath")
	breath.reset_presentation()
	_attention_timer = Timer.new()
	_attention_timer.one_shot = true
	_attention_timer.wait_time = 1.1
	_attention_timer.timeout.connect(func() -> void:
		if _enabled and not _talking: sprite.play(&"idle_down"))
	add_child(_attention_timer)
	_old = {"position": npc.position, "frames": sprite.sprite_frames, "animation": sprite.animation,
		"scale": sprite.scale, "sprite_position": sprite.position, "portrait": npc.dialogue_portrait,
		"filter": sprite.texture_filter, "aura": npc.idle_aura.visible}
	nameplate = Nameplate.new()
	nameplate.name = "ReviewNameplate"
	nameplate.npc_name = "Eira"
	nameplate.role_name = "Skill Mentor"
	nameplate.position = Vector2(12, -62)
	npc.add_child(nameplate)
	npc.proximity_changed.connect(_on_proximity_changed)
	npc.dialogue_requested.connect(_on_dialogue_requested)
	hub.dialogue_panel.dialogue_closed.connect(_on_dialogue_closed)
	frames = SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"idle_down")
	frames.set_animation_speed(&"idle_down", 4.0)
	for index in 8:
		var frame := AtlasTexture.new()
		frame.atlas = IDLE
		frame.region = Rect2(Vector2(index % 4, index / 4) * 96, Vector2(96, 96))
		frame.filter_clip = true
		frames.add_frame(&"idle_down", frame, 2.0 if index == 0 or index == 7 else 1.0)

func set_enabled(value: bool) -> void:
	_enabled = value
	_attention_timer.stop()
	nameplate.visible = value
	var breath: Timer = npc.get_node("IdleBreath")
	breath.stop()
	breath.reset_presentation()
	npc.position = EIRA_POSITION if value else _old.position
	npc.dialogue_portrait = PORTRAIT if value else _old.portrait
	npc.idle_aura.visible = false if value else _old.aura
	sprite.sprite_frames = frames if value else _old.frames
	sprite.position = Vector2(0, -16) if value else _old.sprite_position
	sprite.scale = Vector2(.5, .5) if value else _old.scale
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if value else _old.filter
	sprite.play(&"idle_down" if value else _old.animation)
	if not value:
		breath.start()
	elif _talking:
		sprite.pause()
		sprite.frame = 0
	nameplate.set_near(npc._player_inside)

func greet() -> void:
	if not _enabled or _talking: return
	sprite.pause()
	sprite.frame = 0
	_attention_timer.start()

func _on_proximity_changed(near: bool, _prompt: String, _icon: Texture2D) -> void:
	nameplate.set_near(near)

func _on_dialogue_requested(_speaker: String, _lines: Array[String], _portrait: Texture2D) -> void:
	if _enabled:
		_talking = true
		sprite.pause()
		sprite.frame = 0

func _on_dialogue_closed(_completed: bool) -> void:
	if not _talking:
		return
	_talking = false
	if _enabled:
		sprite.play(&"idle_down")
