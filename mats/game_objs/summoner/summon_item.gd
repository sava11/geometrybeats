class_name Summon_item_base
extends Resource
@export_group("file")
@export_file("*.tscn;*.scn") var scene
@export var shape:Shape2D
@export_group("items","item")
@export var item_position:CustomPosition
@export var item_speed:FloatVectValue
@export var item_rotation:FloatVectValue
