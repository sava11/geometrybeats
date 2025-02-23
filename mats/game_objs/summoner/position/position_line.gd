class_name PositionLine extends CustomPosition
@export var centered:=false
@export_range(0,99,0.001,"or_greater") var line_size:float
@export_range(1,99,0.001,"or_greater") var count:int
@export var angle:float=0
func _prepare_data(args:=[]):
	for e in range(count):
		var v:=Vector2.RIGHT
		var ang:=rad_to_deg(-atan2(-v.y,v.x))+angle
		v=Vector2(cos(deg_to_rad(ang)),sin(deg_to_rad(ang)))
		if centered:
			v*=snapped(randi_range(-line_size/2,line_size/2),0.001)
		else:
			v*=snapped(randi_range(0,line_size),0.001)
		positions.append(v)
