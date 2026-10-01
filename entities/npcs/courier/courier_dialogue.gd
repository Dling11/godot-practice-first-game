extends DialogueNpc

var hub: Node

func can_interact() -> bool:
	# Fixed services retain F priority if interaction radii overlap along the delivery circuit.
	for node_name in ["Skillkeeper","WeaponMerchant","Rootweaver","Umi","ExpeditionAltar"]:
		var service := hub.get_node("World/Actors/"+node_name)
		if service.get("_player_inside") == true: return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	if not can_interact(): return
	super._unhandled_input(event)
