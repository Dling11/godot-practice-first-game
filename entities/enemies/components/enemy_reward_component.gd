class_name EnemyRewardComponent
extends Node

## Observes an enemy's authoritative death and grants data-defined session rewards.

@export var health_component: HealthComponent

var _granted := false


func _ready() -> void:
	if health_component == null:
		push_error("EnemyRewardComponent requires a HealthComponent.")
		return
	health_component.died.connect(_grant_rewards)


func _grant_rewards() -> void:
	if _granted:
		return
	_granted = true
	var enemy := get_parent()
	if enemy == null or not "definition" in enemy or not "target" in enemy:
		return
	var definition := enemy.get("definition") as EnemyDefinition
	var recipient := enemy.get("target") as Player
	if definition == null or recipient == null or recipient.progression_component == null:
		return
	recipient.progression_component.grant_rewards(definition.experience_reward, definition.coin_reward)
