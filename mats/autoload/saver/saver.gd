class_name save_loader extends Node
signal start_loading_data();
signal data_loaded();
signal start_saving_data();
signal data_saved();
@export var auto_update:bool=false
@export var sn:data_to_save
@onready var path=""
var saved_data:={}
func _ready():
	if sn!=null:
		path=str(get_path())
		var res=sld.global_saved_data.get(path)
		if res!=null:
			load_data(res)
		else:
			sld.global_saved_data.merge(save_data(),true)
	set_process(auto_update and sn!=null)
func save_data_to_global_dictionary():
	var can_save:=false
	for e in sn.data:
		var node:Node=get_node(e.node)
		for el in e.data:
			var value=node.get(el)
			if value is Vector2 or value is Vector2i:
				if saved_data[str(node.get_path())][el].has("x") and saved_data[str(node.get_path())][el].has("y"):
					value=saved_data[str(node.get_path())][el]
			if value!=saved_data[str(node.get_path())][el]:
				can_save=true
				break
	if can_save:
		sld.global_saved_data.merge(save_data(),true)
func remove_data_from_global_dictionary():
	sld.global_saved_data.erase(path)
func save_data()->Dictionary:
	emit_signal("start_saving_data")
	saved_data={}
	for e in sn.data:
		var node:Node=get_node(e.node)
		var node_saved_data:={}
		for el in e.data:
			var value=node.get(el)
			if value!=null:
				if value is Vector2 or value is Vector2i:
					value={"x":value.x,"y":value.y}
				node_saved_data.merge({el:value},true)
		saved_data.merge({str(node.get_path()):node_saved_data},true)
	emit_signal("data_saved")
	return {str(get_path()):saved_data}
func load_data(loaded_data:Dictionary)->void:
	emit_signal("start_loading_data")
	saved_data=loaded_data
	for e in sn.data:
		var node:Node=get_node(e.node)
		var node_loaded_data:Dictionary=loaded_data[str(node.get_path())].duplicate(true)
		for el in e.data:
			if node_loaded_data.has(el):
				var value=node_loaded_data[el]
				if node.get(el) is Vector2:
					value=Vector2(value.x,value.y)
				elif node.get(el) is Vector2i:
					value=Vector2i(value.x,value.y)
				node.set(el,value)
	emit_signal("data_loaded")
func _process(delta):
	save_data_to_global_dictionary()
