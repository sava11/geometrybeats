class_name CustomPosition
extends Resource
@export var positions:Array[Vector2]=[Vector2.ZERO]
func _prepare_data(args:=[]):
	positions.append(Vector2.ZERO)
func exec(args:=[])->Array[Vector2]:
	positions.clear()
	_prepare_data(args)
	return positions
