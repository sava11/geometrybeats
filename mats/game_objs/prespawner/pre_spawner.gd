class_name PreSpawner
extends Node2D
@export var add_to:Node
@export var spawn:=false
@export var one_shoot:=false
@export var summon_offset:=Vector2.ZERO
@export var collision_shape:Shape2D
@export var summon_time:=1.0
@export var curve:Curve
enum del_obj{none,prespawner,everyvhere_shout}
@export var obj_event_time:float=1
@export var on_deleetion_object:=del_obj.none
@export var on_deleetion_object_data:Dictionary
func _physics_process(delta: float) -> void:
	if add_to!=null and spawn:
		var scn:Node2D=MoveHitBox.new()
		scn.curve=curve
		scn.oneshout=true
		scn.deletion_timer=summon_time
		scn.global_position=global_position
		scn.command_id=-1
		scn.local_event_time=obj_event_time
		var col:=CollisionShape2D.new()
		if col!=null:col.shape=collision_shape
		match on_deleetion_object:
			#del_obj.none:
				#pass
			del_obj.prespawner:pass
			del_obj.everyvhere_shout:
				var s=EvrywhereShouters.new()
				for e in on_deleetion_object_data.keys():
						s.set(e,on_deleetion_object_data[e])
				s.angles=s.create_angles()
				var width:=5.0
				var win_w:int=ProjectSettings.get("display/window/size/viewport_width")
				#var win_h:int=ProjectSettings.get("display/window/size/viewport_height")
				for e:float in s.angles:
					var pol=PackedVector2Array([])
					for p:Vector2 in [Vector2(0,-width/2),Vector2(0,width/2),
					Vector2(win_w,width/2),Vector2(win_w,-width/2)]:
						var ang:=rad_to_deg(-atan2(-p.y,p.x))
						pol.append(Vector2(cos(deg_to_rad(ang+e)),sin(deg_to_rad(ang+e)))*p.length_squared())
					scn.new_polygons.append(pol)
				scn.local_event.connect((func():
					
					s.add_to=add_to
					s.global_position=scn.global_position
					add_to.add_child(s)
					))	
		scn.add_child(col)
		col.global_position=global_position+summon_offset
		add_to.add_child(scn)
		spawn=false
