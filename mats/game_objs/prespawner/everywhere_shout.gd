class_name EvrywhereShouters
extends Node2D
@export var add_to:Node
@export var spawn:=false
@export var shout_time:=0.0
@export var one_shoot:=false
@export var collision_shape:Shape2D
@export_range(0,360,0.001,)var summon_range:=15
@export_range(0,9,1,"or_greater","hide_slider")var summon_count_from:=10
@export_range(0,9,1,"or_greater","hide_slider")var summon_count_to:=10
@export_range(0,9,1,"or_greater","hide_slider")var speed_from:=350
@export_range(0,9,1,"or_greater","hide_slider")var speed_to:=350
var angles=[]
func _ready() -> void:
	if angles.is_empty():
		angles=create_angles()
func create_angles():
	var angs=[]
	var count=randi_range(summon_count_from,summon_count_to)
	var ang:float=summon_range/float(count)
	for e in range(count):
		angs.append(rotation_degrees+ang*e-summon_range/2)
	return angs
func _physics_process(delta: float) -> void:
	if add_to!=null and spawn:
		for e in angles:
			var scn:Node2D=MoveHitBox.new()
			scn.deletion_timer=0
			scn.global_position=global_position
			scn.collision_layer=8
			var col:=CollisionShape2D.new()
			if col!=null:col.shape=collision_shape
			var vec:=Vector2(
				cos(deg_to_rad(e)),
				sin(deg_to_rad(e))
			)
			scn.speed_dir=vec
			scn.speed=randi_range(speed_from,speed_to)
			scn.add_child(col)
			add_to.add_child(scn)
		spawn=false
		if one_shoot:
			queue_free()
