class_name Collectable extends Area2D

@export var speed: float = 125
@export var points: PackedVector2Array = PackedVector2Array()
@export var rotation_speed: float = 0.0

func _physics_process(delta: float) -> void:
	if points.size() > 0:
		var target := points[0]
		var dir := (target - global_position).normalized()
		global_position += dir * speed * delta
		rotation_degrees += rotation_speed * delta
		if global_position.distance_to(target) < 10:
			points.remove_at(0)
	else:
		queue_free()
