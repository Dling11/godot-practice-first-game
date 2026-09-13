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
@export_multiline var lore := ""

const RANK_NAMES := ["Mortal", "Resonant", "Ascendant", "Unbound"]
const FAMILIES := ["crosscut_advance", "griefwake", "starfall_step", "oathstorm"]
const NAMES := [
	["Crosscut Advance", "Silver Refrain", "Horizon Cleaver", "Sever the Horizon"],
	["Griefwake", "Echoes Below", "Fault of Heaven", "The Earth Remembers"],
	["Starfall Step", "Comet Return", "Astral Passage", "Beyond the Firmament"],
	["Oathstorm", "Choir of Steel", "Heaven's Silence", "The Unwritten Dawn"]
]
const STORIES := [
	"A promise carried in both hands. King learns to put his next step inside the opening his blade creates.",
	"The ground remembers every weight it has carried. King gives that memory a voice.",
	"For one breath, the distance between danger and safety belongs to him.",
	"He repeats no prayer. Every turning stroke is another word of an oath he refuses to abandon."
]

func at_rank(next_rank: int) -> KingOathDefinition:
	var result := duplicate(true) as KingOathDefinition
	result.rank = clampi(next_rank,0,3)
	result._configure()
	return result

func _configure() -> void:
	ability_id = FAMILIES[technique]
	display_name = NAMES[technique][rank]
	hud_name = ["CROSSCUT","GRIEFWAKE","STARFALL","OATHSTORM"][technique]
	lore = STORIES[technique]
	weapon_damage_multiplier = 1.0
	grants_invulnerability = false
	grants_super_armor = false
	non_final_knockback_multiplier = .18
	non_final_stagger_multiplier = .3
	knockback_strength = 100.0
	stagger_seconds = .5
	beat_times.clear()
	beat_radii.clear()
	beat_distances.clear()
	strike_damage_multipliers.clear()
	activation_mode = ActivationMode.IMMEDIATE_DIRECTIONAL
	impact_weight = ImpactWeight.HEAVY
	var count := 2
	match technique:
		Technique.CROSSCUT:
			count = [2,2,3,4][rank]
			wind_up_seconds = .18
			active_seconds = count*.22
			recovery_seconds = .19
			cooldown_seconds = 5.0
			travel_range = 28+rank*7
			travel_seconds = .14
			for i in count:
				_add_beat(i*.22,48+rank*14,0,.85+rank*.12 if i<count-1 else 1.05+rank*.2)
		Technique.GRIEFWAKE:
			count = [3,4,5,6][rank]
			wind_up_seconds = .34
			active_seconds = count*.16+.12
			recovery_seconds = .23
			cooldown_seconds = 8.0
			for i in count:
				_add_beat(i*.16,48+rank*15+i*4,28+i*(34+rank*4),.45+rank*.12 if i<count-1 else 1.1+rank*.3)
		Technique.STARFALL:
			count = [1,2,2,3][rank]
			activation_mode = ActivationMode.GROUND_TARGETED
			wind_up_seconds = .12
			travel_seconds = .24
			travel_range = 180+rank*20
			active_seconds = travel_seconds+count*.18+.1
			recovery_seconds = .14
			cooldown_seconds = 7.5
			for i in count:
				_add_beat(travel_seconds+i*.18,56+rank*13+i*18,0,1.25+rank*.2 if i==0 else .65+rank*.2)
		Technique.OATHSTORM:
			count = [3,4,5,7][rank]
			activation_mode = ActivationMode.SELF_AREA
			wind_up_seconds = .42
			active_seconds = count*.19+.12
			recovery_seconds = .32
			cooldown_seconds = 17.0
			impact_weight = ImpactWeight.DEVASTATING
			for i in count:
				var reach := lerpf(62+rank*14,108+rank*38,float(i)/maxi(count-1,1))
				_add_beat(i*.19,reach,0,.55+rank*.1 if i<count-1 else 1.5+rank*.45)
	var shape := CircleShape2D.new()
	shape.radius = beat_radii[0]
	hitbox_shape = shape
	description = "%s\n%s form · %d contacts · %.1fs cooldown\n%s" % [
		["Advance through two-handed cuts.","Release successive ground ruptures along your committed direction.","Cross danger, then release a falling-star impact.","Turn your greatsword through expanding waves of white steel."][technique],
		RANK_NAMES[rank],count,cooldown_seconds,lore]

func _add_beat(time: float, radius: float, distance: float, multiplier: float) -> void:
	beat_times.append(time)
	beat_radii.append(radius)
	beat_distances.append(distance)
	strike_damage_multipliers.append(multiplier)
