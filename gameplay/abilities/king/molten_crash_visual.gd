extends Node2D

## Registered sprite animation observes contact; never owns damage or stun.
const Sword = preload("res://assets/vfx/abilities/king/molten_crash/sword.png")
const Burst = preload("res://assets/vfx/abilities/king/molten_crash/burst.png")
const HeatRing = preload("res://assets/vfx/abilities/king/molten_crash/aftershock.png")
const Swing = preload("res://assets/audio/sfx/player/greatsword/cleave.wav")
const Impact = preload("res://assets/audio/sfx/abilities/king/riftbreak_ground_slam.wav")
var source: Player
var component: AbilityComponent
var radius := 72.0
var form := MoltenCrashDefinition.Form.FOUNDATION
var _sword: Sprite2D
var _burst: Sprite2D
var _ring: Sprite2D
var _age := 0.0
var _after := 0.0
var _released := false
var _swing_played := false
var _feedback: CombatFeedbackPresenter
var _ring_age := -1.0

const FOUNDATION_SHADER := """
shader_type canvas_item;
void fragment() {
	vec4 src = texture(TEXTURE, UV);
	float warm = clamp((src.r-src.b)*1.7,0.0,1.0);
	float bright = clamp(src.g*1.55,0.0,1.0);
	vec3 stone = mix(vec3(0.19,0.20,0.23),vec3(0.48,0.46,0.40),bright);
	vec3 light = mix(vec3(0.73,0.64,0.43),vec3(1.0,0.96,0.74),bright);
	COLOR = vec4(mix(stone,light,warm),src.a*COLOR.a);
}
"""

func _ready() -> void:
	add_to_group("molten_crash_review_effects")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ancestor := source.get_parent()
	while ancestor != null and _feedback == null:
		_feedback = ancestor.get_node_or_null("Services/CombatFeedback") as CombatFeedbackPresenter
		ancestor = ancestor.get_parent()
	_sword = _sprite(Sword,.48)
	_sword.z_index = -1
	_burst = _sprite(Burst,radius*2.0/180.0)
	_burst.z_index = -2
	_burst.visible = false
	if form == MoltenCrashDefinition.Form.FOUNDATION:
		var shader := Shader.new()
		shader.code = FOUNDATION_SHADER
		var material := ShaderMaterial.new()
		material.shader = shader
		_sword.material = material
		_burst.material = material
	_ring = _sprite(HeatRing,86.0*2.0/232.0)
	_ring.z_index = -1
	_ring.visible = false
	if form == MoltenCrashDefinition.Form.MATURE:
		_ring.modulate = Color(1.0,.90,.72)
	_frame(_sword,0)

func _sprite(texture: Texture2D, size: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.scale = Vector2.ONE*size
	add_child(sprite)
	return sprite

func _frame(sprite: Sprite2D, index: int) -> void:
	sprite.region_rect = Rect2(Vector2(index%4,index/4)*512.0,Vector2(512,512))

func release() -> void:
	_released = true
	_after = 0.0
	_sword.position = Vector2.ZERO
	_frame(_sword,7)
	_burst.visible = true
	_frame(_burst,0)
	_sound(Impact,-12.5,.88)
	if is_instance_valid(_feedback):
		_feedback.request_camera_pulse(3.2)

func prepare_aftershock() -> void:
	_ring_age = 0.0
	_ring.visible = true
	_frame(_ring,0)

func release_aftershock() -> void:
	_ring_age = maxf(_ring_age,.14)
	_frame(_ring,4)
	_sound(Impact,-19.0,1.2)
	if is_instance_valid(_feedback):
		_feedback.request_camera_pulse(1.6 if form == MoltenCrashDefinition.Form.AWAKENED else 2.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated:
		queue_free()
		return
	_age += delta
	if not _released:
		var t := clampf(_age/component.definition.wind_up_seconds,0.0,1.0)
		_frame(_sword,mini(6,int(t*7)))
		# Brief lift, then accelerating descent into the authoritative contact.
		_sword.position.y = lerpf(-8.0,-25.0,sin(t/.65*PI*.5)) if t<.65 else lerpf(-25.0,0.0,pow((t-.65)/.35,2))
		if t>.5 and not _swing_played:
			_swing_played = true
			_sound(Swing,-18.0,1.1)
	else:
		_after += delta
		_frame(_sword,mini(15,7+int(_after/.028)))
		_sword.visible = _after<.25
		_frame(_burst,mini(15,int(_after/.040)))
		_burst.modulate.a = clampf((.95-_after)/.35,0.0,1.0)
		if _ring_age >= 0.0:
			_ring_age += delta
			_frame(_ring,mini(15,int(_ring_age/.035)))
			_ring.modulate.a = clampf((.60-_ring_age)/.18,0.0,1.0)
			if _ring_age >= .14:
				_burst.modulate.a *= .32
		if _after>=.95:
			queue_free()

func _sound(stream: AudioStream, volume: float, pitch: float) -> void:
	if DisplayServer.get_name()=="headless":
		return
	var sound := AudioStreamPlayer2D.new()
	sound.stream = stream
	sound.volume_db = volume
	sound.pitch_scale = pitch
	sound.bus = &"SFX"
	add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()
