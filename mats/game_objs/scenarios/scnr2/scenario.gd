extends Scenario

func _post_ready():
	pass

func _post_physics_process(delta: float):
	pass

func _action_activated(track: int, time: float):
	$act/PreSpawner.global_position = get_rand_pos()
	$act/PreSpawner.spawn = true

func _level_ended(node: Scenario):
	pass

func _on_collection_event_activated(id: int, time: float) -> void:
	pass
	
