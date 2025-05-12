extends Scenario


func _on_action_activated(track: int, time: float) -> void:
	if track==0:
		$act/Node2D.create_hit_box()
