class_name MoveHitBox
extends HitBox
@export_range(0, 100, 1, "or_greater") var damage_points: int = 1
@export var speed:float=350
@export var speed_dir:=Vector2.ZERO
@export var rotation_speed: float = 0.0
var safe_area_size: Vector2
var safe_area_start: Vector2 = Vector2(-640, -640)
func _post_ready():
	safe_area_size = get_tree().root.get_viewport().get_visible_rect().size

func _phy_proc(delta:float) -> void:
	global_position += speed_dir*speed * delta
	rotation_degrees += rotation_speed *delta
	if (global_position.x > safe_area_size.x - safe_area_start.x or 
	global_position.x < safe_area_start.x or 
	global_position.y > safe_area_size.y - safe_area_start.y or 
	global_position.y < safe_area_start.y):queue_free()
