class_name FloatVectValue
extends Resource
@export var speed_var_name:String=""
@export var value:float
@export var vec:=Vector2.RIGHT
func get_move()->Vector2:
	return vec.normalized()*value
