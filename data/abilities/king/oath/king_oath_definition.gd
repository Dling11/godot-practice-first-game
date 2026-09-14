class_name KingOathDefinition
extends AbilityDefinition

## Immutable family/rank tuning. Rank changes create a new resource between casts.
enum Technique { CROSSCUT, GRIEFWAKE, STARFALL, OATHSTORM }
@export var technique: Technique = Technique.CROSSCUT
@export_range(0,3) var rank := 0
@export var beat_times := PackedFloat32Array()
@export var beat_radii := PackedFloat32Array()
@export var beat_distances := PackedFloat32Array()
@export var travel_seconds := 0.0
@export var travel_range := 0.0
@export var core_radius := 0.0
@export var outer_damage_ratio := 0.4
@export_multiline var lore := ""

const RANK_NAMES := ["Mortal", "Resonant", "Ascendant", "Unbound"]
const FAMILIES := ["crosscut_advance", "griefwake", "starfall_step", "oathstorm"]
const NAMES := [
	["Crosscut Advance", "Silver Refrain", "Horizon Cleaver", "Sever the Horizon"],
	["Griefwake", "Echoes Below", "Fault of Heaven", "The Earth Remembers"],
	["Breakstep", "Thread the Needle", "Astral Passage", "Beyond the Firmament"],
	["Last Oath", "Oath Unbroken", "Heaven's Silence", "The Unwritten Dawn"]
]
const STORIES := [
	"A promise carried in both hands. King learns to put his next step inside the opening his blade creates.",
	"The ground remembers every weight it has carried. King gives that memory a voice.",
	"For one breath, the distance between danger and safety belongs to him.",
	"He repeats no prayer. He plants his feet, remembers his promise, and brings the weight of it down."
]

func at_rank(next_rank: int) -> KingOathDefinition:
	var result := duplicate(true) as KingOathDefinition
	result.rank = clampi(next_rank,0,3)
	result._configure()
	return result

func _configure() -> void:
	ability_id = FAMILIES[technique]
	display_name = NAMES[technique][rank]
	hud_name = ["CROSSCUT","GRIEFWAKE","BREAKSTEP","LAST OATH"][technique]
	lore = STORIES[technique]
	weapon_damage_multiplier = 1.0
	grants_invulnerability = false
	grants_super_armor = false
	dash_cancelable = true
	travel_range = 0.0
	travel_seconds = 0.0
	non_final_knockback_multiplier = .18
	non_final_stagger_multiplier = .3
	knockback_strength = 100.0
	stagger_seconds = .14
	stun_seconds = 0.0
	beat_times.clear()
	beat_radii.clear()
	beat_distances.clear()
	strike_damage_multipliers.clear()
	activation_mode = ActivationMode.IMMEDIATE_DIRECTIONAL
	impact_weight = ImpactWeight.HEAVY
	var count := 2
	match technique:
		Technique.CROSSCUT:
			count = 2
			wind_up_seconds = .10
			active_seconds = .28
			recovery_seconds = .10
			cooldown_seconds = 5.0
			travel_range = 24+rank*4
			travel_seconds = .12
			for i in count:
				_add_beat(i*.16,46+rank*6,0,.9+rank*.18 if i==0 else 1.1+rank*.22)
		Technique.GRIEFWAKE:
			count = 1
			activation_mode = ActivationMode.GROUND_TARGETED
			wind_up_seconds = .20
			active_seconds = .10
			recovery_seconds = .12
			cooldown_seconds = 8.0
			travel_range = 190+rank*25
			core_radius = 27+rank*4
			outer_damage_ratio = .55
			_add_beat(0,58+rank*10,0,2.4+rank*.5)
		Technique.STARFALL:
			count = 0
			wind_up_seconds = .06
			travel_seconds = .20
			travel_range = 100+rank*10
			active_seconds = travel_seconds
			recovery_seconds = .06
			cooldown_seconds = 6.0
			dash_cancelable = false
		Technique.OATHSTORM:
			count = 1
			wind_up_seconds = .28
			active_seconds = .10
			recovery_seconds = .24
			cooldown_seconds = 13.0
			impact_weight = ImpactWeight.DEVASTATING
			core_radius = 28+rank*3
			outer_damage_ratio = .32
			knockback_strength = 180.0
			_add_beat(0,85+rank*16,40,4.0+rank*.8)
	var shape := CircleShape2D.new()
	shape.radius = beat_radii[0] if not beat_radii.is_empty() else 1.0
	hitbox_shape = shape
	description = "%s\n%s form · %d contacts · %.1fs cooldown\n%s" % [
		["Two advancing cuts. Dash out to forfeit the remaining cut.","Aim a ground eruption. Strong center; weaker rim slows ordinary foes. Move again before it lands.","Step through danger. Evading a real hit primes your next basic cut for +50% damage (2s). Complete the step to link a rupture.","One decisive forward impact. Powerful small center; weaker wide rim pushes enemies away."][technique],
		RANK_NAMES[rank],count,cooldown_seconds,lore]

func _add_beat(time: float, radius: float, distance: float, multiplier: float) -> void:
	beat_times.append(time)
	beat_radii.append(radius)
	beat_distances.append(distance)
	strike_damage_multipliers.append(multiplier)
