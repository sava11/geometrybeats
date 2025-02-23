class_name Summoner
extends Node2D
@export var add_to:Node
@export var spawn:=false
@export var shout_time:=0.2
@export var collision_shape:Shape2D
@export var centered:=false
@export var angle:float=0
@export_range(0,99,0.001,"or_greater") var line_size:float
@export_range(0,9,1,"or_greater","hide_slider")var speed_from:=350
@export_range(0,9,1,"or_greater","hide_slider")var speed_to:=350
var temp_time:float=0.0
func _physics_process(delta: float) -> void:
	temp_time+=delta
	if add_to!=null and spawn and temp_time>=shout_time:
		var scn:Node2D=MoveHitBox.new()
		scn.deletion_timer=0
		scn.command_id=-1
		var col:=CollisionShape2D.new()
		if col!=null:col.shape=collision_shape
		var v:=Vector2.RIGHT
		scn.global_rotation_degrees=angle+global_rotation_degrees
		var ang:=rad_to_deg(-atan2(-v.y,v.x))+angle+global_rotation_degrees
		v=fnc.move(ang)
		if centered:
			v*=snapped(randi_range(-line_size/2,line_size/2),0.001)
		else:
			v*=snapped(randi_range(0,line_size),0.001)
		scn.global_position=global_position+v
		scn.speed_dir=fnc.move(global_rotation_degrees)
		scn.speed=randi_range(speed_from,speed_to)
		scn.add_child(col)
		add_to.add_child(scn)
		#spawn=false
		temp_time=0
