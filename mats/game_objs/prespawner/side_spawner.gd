class_name SideSpawner
extends Node2D
@export var add_to:Node
@export_range(0.001, 99, 0.001, "or_greater") var time_to_delete:=2.0
@export var curve:Curve
var half_y:RectangleShape2D
var half_x:RectangleShape2D
var wsize:Vector2
func _ready() -> void:
	wsize=Vector2(
		ProjectSettings.get("display/window/size/viewport_width"),
		ProjectSettings.get("display/window/size/viewport_height")
	)
	half_x=RectangleShape2D.new()
	half_x.size=Vector2(wsize.x/2,wsize.y)
	half_y=RectangleShape2D.new()
	half_y.size=Vector2(wsize.x,wsize.y/2)

func _physics_process(delta: float) -> void:
	pass
var sides:=PackedVector2Array([
	Vector2(0,0),Vector2(0,1),
	Vector2(1,0),Vector2(1,1)
	])
var current_sides:=PackedVector2Array([
	Vector2(0,0),Vector2(0,1),
	Vector2(1,0),Vector2(1,1)
	])
func generate_side()->HitBox:
	if current_sides.is_empty():
		current_sides=sides.duplicate()
	var hit:=HitBox.new()
	var c:=CollisionShape2D.new()
	var id:=fnc.rnd.randi()%current_sides.size()
	var v:=current_sides[id]
	current_sides.remove_at(id)
	c.shape=[half_x,half_y][v.x]
	if c.shape == half_x:
		hit.global_position=[
			Vector2(half_x.size.x/2, wsize.y/2),
			Vector2(wsize.x-half_x.size.x/2, wsize.y/2)
		][v.y]
	else:
		hit.global_position=[
			Vector2(wsize.x/2, wsize.y-half_y.size.y/2),
			Vector2(wsize.x/2, half_y.size.y/2)
		][v.y]
	hit.deletion_timer=time_to_delete
	hit.collision_layer=8
	hit.oneshout=true
	hit.curve=curve
	hit.add_child(c)
	return hit

func create_hit_box():
	var scn=generate_side()
	add_to.add_child(scn)
