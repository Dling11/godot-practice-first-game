extends Node2D

const Burst = preload("res://gameplay/abilities/king/oath/king_oath_burst.gd")
const Trail = preload("res://assets/vfx/abilities/king/greatsword/white_slash_96x96.png")
const Storm = preload("res://assets/vfx/abilities/king/oath/storm_192.png")
const Fracture = preload("res://assets/vfx/abilities/king/oath/fracture_192.png")
const Charge = preload("res://assets/audio/sfx/player/oath/charge.wav")
const Sounds := [preload("res://assets/audio/sfx/player/oath/crosscut.wav"),preload("res://assets/audio/sfx/player/oath/griefwake.wav"),preload("res://assets/audio/sfx/player/oath/starfall.wav"),preload("res://assets/audio/sfx/player/oath/storm.wav")]
const Finale = preload("res://assets/audio/sfx/player/oath/finale.wav")
var actor: Player
var _charge: Node2D
var _sounds: Array[AudioStreamPlayer2D] = []
var _voice := 0
var _trail_clock := 0.0
var _travel: KingOathComponent

func _ready() -> void:
	actor=get_parent() as Player
	z_index=1
	for i in 5:
		var sound := AudioStreamPlayer2D.new()
		sound.bus=&"SFX"
		sound.volume_db=-17
		sound.max_distance=900
		add_child(sound)
		_sounds.append(sound)
	actor.ready.connect(_bind)
	set_process(false)

func _bind() -> void:
	for ability in actor.get_all_ability_components():
		if ability is KingOathComponent:
			ability.phase_changed.connect(_phase.bind(ability))
			ability.strike_started.connect(_strike.bind(ability))
			ability.ability_finished.connect(_finish)

func _phase(phase: int, duration: float, ability: KingOathComponent) -> void:
	if phase==AbilityComponent.Phase.WIND_UP:
		_clear_charge()
		var tuning := ability.definition as KingOathDefinition
		_charge=_burst(Storm,actor.global_position,28+tuning.rank*7,duration)
		_charge.charge=true
		_play(Charge,1.12-tuning.rank*.05,-22)
	elif phase==AbilityComponent.Phase.ACTIVE:
		_clear_charge()
		if (ability.definition as KingOathDefinition).technique==KingOathDefinition.Technique.STARFALL:
			_travel=ability
			_trail_clock=0
			set_process(true)

func _strike(index: int, count: int, _duration: float, ability: KingOathComponent) -> void:
	var tuning := ability.definition as KingOathDefinition
	var texture: Texture2D = Fracture if tuning.technique==KingOathDefinition.Technique.GRIEFWAKE else Storm
	var burst := _burst(texture,ability.contact_origin,ability.contact_radius,.48 if tuning.technique!=KingOathDefinition.Technique.OATHSTORM else .42)
	if tuning.technique==KingOathDefinition.Technique.CROSSCUT:
		burst.texture=Trail
		burst.cleave=true
		burst.follow_actor=actor
		burst.reverse=index%2==1
		burst.points=(ability.collision_shape.shape as ConvexPolygonShape2D).points
		burst.rotation=ability.get_cast_direction().angle()
		burst.life=.21
	else:
		burst.z_index=-1
		if tuning.technique==KingOathDefinition.Technique.OATHSTORM:
			burst.rotation=index*.47
		if tuning.technique==KingOathDefinition.Technique.STARFALL and index==0:
			var ground := _burst(Fracture,ability.contact_origin,ability.contact_radius*.8,.52)
			ground.z_index=-2
	var final := index==count-1
	_play(Finale if final and tuning.rank>=2 else Sounds[tuning.technique],1.07-index*.025-tuning.rank*.035,-15 if final else -20)

func _burst(texture: Texture2D, at: Vector2, radius: float, duration: float) -> Node2D:
	var burst := Burst.new()
	burst.texture=texture
	burst.radius=radius
	burst.life=duration
	add_child(burst)
	burst.top_level=true
	burst.global_position=at
	return burst

func _process(delta: float) -> void:
	if not is_instance_valid(_travel) or _travel.phase!=AbilityComponent.Phase.ACTIVE or _travel.elapsed>=(_travel.definition as KingOathDefinition).travel_seconds:
		set_process(false)
		return
	_trail_clock-=delta
	if _trail_clock>0:
		return
	_trail_clock=.05
	var body: AnimatedSprite2D = actor.get_node("VisualRoot/Body")
	var ghost := Sprite2D.new()
	ghost.texture=body.sprite_frames.get_frame_texture(body.animation,body.frame)
	ghost.offset=body.offset
	ghost.modulate=Color(.7,.9,1,.35)
	ghost.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(ghost)
	ghost.top_level=true
	ghost.global_position=body.global_position
	var tween := ghost.create_tween()
	tween.tween_property(ghost,"modulate:a",0.0,.18)
	tween.tween_callback(ghost.queue_free)

func _finish() -> void:
	_clear_charge()
	set_process(false)
	# A cancelled channel must not leave opaque skill layers hiding the next tell.
	if actor.is_defeated or actor.is_in_hit_recovery():
		for child in get_children():
			if child is Burst or child is Sprite2D:
				child.queue_free()
		for sound in _sounds:
			sound.stop()

func _clear_charge() -> void:
	if is_instance_valid(_charge):
		_charge.queue_free()
	_charge=null

func _play(stream: AudioStream, pitch: float, volume: float) -> void:
	if DisplayServer.get_name()=="headless":
		return
	var sound := _sounds[_voice%_sounds.size()]
	_voice+=1
	sound.stream=stream
	sound.pitch_scale=pitch
	sound.volume_db=volume
	sound.play()
