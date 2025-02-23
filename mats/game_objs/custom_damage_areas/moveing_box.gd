class_name MoveHitBox
extends HitBox
signal local_event
@export_range(0, 100, 1, "or_greater") var damage_points: int = 1
@export_range(0, 1, 0.001) var enabled: float = 1.0
@export_range(0, 1, 0.001) var hited: float = 0.95
@export var speed:float=350
@export var speed_dir:=Vector2.ZERO
@export var rotation_speed: float = 0.0
@export var oneshout:=false
@export var curve:Curve
@export var local_event_time:float=0
var evented:=false
var safe_area_size: Vector2
var safe_area_start: Vector2 = Vector2(-640, -640)
var time:=0.0
func _post_ready():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	safe_area_size = get_tree().root.get_viewport().get_visible_rect().size
	if oneshout:
		color.a=0
		enabled=false
		if time>=local_event_time and !evented:
			emit_signal("local_event")
			evented=true

func _phy_proc(delta:float) -> void:
	if oneshout:
		time+=delta
		enabled=curve.sample_baked(time/deletion_timer)
		if time>=local_event_time and !evented:
			emit_signal("local_event")
			evented=true
	color.a = enabled
	set_deferred("monitorable", enabled >= hited)
	set_deferred("monitoring", enabled >= hited)
	global_position += speed_dir*speed * delta
	rotation_degrees += rotation_speed *delta
	if (global_position.x > safe_area_size.x - safe_area_start.x or 
	global_position.x < safe_area_start.x or 
	global_position.y > safe_area_size.y - safe_area_start.y or 
	global_position.y < safe_area_start.y):queue_free()
