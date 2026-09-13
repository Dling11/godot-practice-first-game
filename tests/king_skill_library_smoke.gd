extends SceneTree
const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var session := root.get_node("RunSession")
	var story := root.get_node("StoryState")
	session.reset_run()
	story.reset_story()
	var scene := Lab.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.clear_simulation()
	var actor: Player=scene.player
	actor._debug_unlimited_skills=false
	var library := actor.get_node("KingSkillLibrary") as KingSkillLibrary
	var initial := library.current_ids()
	var flags: Dictionary=story.create_snapshot().duplicate(true)
	_check(library.is_lab() and library.can_edit(),"Lab edit available")
	_check(library.equip_oath_preview(),"One-button Oath kit")
	_check(library.current_ids()==KingOathDefinition.FAMILIES,"Four new slots")
	for i in 4:
		_check(actor.get_ability_component_for_slot(i+1)==actor.get_node("OathAbility"+str(i+1)),"Slot resolves exact component")
	_check(library.set_preview_rank(3),"Unbound preview")
	_check((actor.get_ability_component_for_slot(4).definition as KingOathDefinition).rank==3,"Rank applies to equipped definition")
	var first := actor.get_ability_component_for_slot(1)
	_check(actor.request_ability(1),"Normal player input starts equipped skill")
	_check(not library.equip("riftbreak",1) and not library.set_preview_rank(0),"No swapping during cast")
	while first.is_casting():
		await physics_frame
	var remaining := first.cooldown_remaining
	_check(library.equip("riftbreak",1),"Legacy and new skills mix")
	_check(library.equip("crosscut_advance",1),"Re-equip cooling skill")
	_check(is_equal_approx(first.cooldown_remaining,remaining),"Unequipped cooldown persists")
	_check(not actor.request_ability(1),"Swap cannot bypass cooldown")
	_check(library.equip("crosscut_advance",2),"Move existing skill")
	_check(library.current_ids()[0]=="griefwake" and library.current_ids()[1]=="crosscut_advance","Existing slot swaps, no duplicate")
	_check(library.set_preview_rank(-1),"Exit preview")
	_check(library.current_ids()==initial,"Preview restores campaign slots")
	_check(story.create_snapshot()==flags and session.king_skill_slots.is_empty(),"Preview cannot mutate story or saved loadout")
	# Same-frame swap/cast used to notify a removed HUD timer.
	library.equip_oath_preview()
	first.clear_cooldown()
	_check(actor.request_ability(1),"Immediate cast after HUD rebuild")
	first.cancel_cast()
	# Defeat interrupts every new component, including travel invulnerability.
	var step := actor.get_node("OathAbility3") as KingOathComponent
	step.request_cast_at(actor.global_position+Vector2(120,0),25)
	while step.phase!=AbilityComponent.Phase.ACTIVE:
		await physics_frame
	_check(step._travel_invulnerable,"Travel-only protection active")
	actor.health_component.is_damage_immune=false
	actor.health_component.set_invulnerable(false)
	var hit := DamageInfo.new(99999,null,Vector2.ZERO)
	actor.health_component.apply_damage(hit)
	_check(actor.is_defeated and not step.is_casting(),"Death cancels new cast")
	_check(not step._travel_invulnerable and not step.hitbox._enabled,"Death clears protection and hitbox")
	scene.queue_free()
	await process_frame
	paused=false # The lab's defeat menu owned a pause; this begins a fresh scene.
	# Production swaps persist stable IDs; future previews remain lab-only.
	story.reset_story()
	session.reset_run()
	var sanctuary := Node.new()
	sanctuary.scene_file_path="res://levels/sanctuary/sanctuary.tscn"
	root.add_child(sanctuary)
	current_scene=sanctuary
	var fresh := preload("res://entities/player/player.tscn").instantiate() as Player
	sanctuary.add_child(fresh)
	var production := fresh.get_node("KingSkillLibrary") as KingSkillLibrary
	_check(production.can_edit() and not production.is_lab(),"Production Sanctuary permits swaps")
	_check(production.equip("crosscut_advance",1),"Production equip accepted")
	_check(session.king_skill_slots[0]=="crosscut_advance","Stable loadout stored in RunSession")
	_check(not production.equip("oathstorm",4),"Cannot equip unlearned skill")
	_check(not production.set_preview_rank(3),"Future preview denied in Sanctuary")
	var second := preload("res://entities/player/player.tscn").instantiate() as Player
	sanctuary.add_child(second)
	_check(second.get_ability_component_for_slot(1) is KingOathComponent,"Fresh player restores saved loadout")
	var crosscut := fresh.get_ability_component_for_slot(1)
	fresh.request_ability(1)
	var original_definition := crosscut.definition
	story.remember_story(&"forest_stage_5_cleared")
	_check(crosscut.definition==original_definition,"Milestone cannot mutate active cast")
	while crosscut.is_casting():
		await physics_frame
	await process_frame
	_check((crosscut.definition as KingOathDefinition).rank==1,"Deferred evolution applies after recovery")
	sanctuary.queue_free()
	await process_frame
	print("KING_SKILL_LIBRARY_PASSED=",checks)
	quit()

func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
		assert(condition,message)
	checks+=1
