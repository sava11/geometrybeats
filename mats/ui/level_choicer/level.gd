@tool
class_name UILevel
extends Control
@export var training:=false:
	set(v):
		training=v
		$pc/mc/c/p2.visible=!v
@export var track_name:String="test"
@export var authors_data:String="voidus"
@export_file("*.tscn;*.scn") var scenario:String="res://mats/game_objs/scenarios/scenario_test.tscn"
@export var points:int=10
@export var neighbors:Array[UILevel]
#@export_flags("runned:1","collected:2","no_hit:4") var stats:=0
func _ready() -> void:
	if !Engine.is_editor_hint():
		for n in neighbors:
			if is_instance_valid(n):
				if n.neighbors.find(self)==-1:
					n.neighbors.append(self)
	size=$pc.size
	$pc/mc/c/p/mc/track/track_name.text=track_name
	$pc/mc/c/p/mc/track/authors.text=authors_data
	
func _draw():
	for n in neighbors:
		if is_instance_valid(n) and n.visible:
			draw_line(n.get_node("pc").size/2.0,(n.global_position-global_position+size/2.0),Color.LIGHT_SKY_BLUE,2)
			
func _physics_process(delta: float) -> void:
	queue_redraw()
func _on_level_end(node:Scenario):
	node.get_parent().queue_free()
	get_tree().current_scene.get_node("cl").show()
	#sld.save_to_file(sld.file_path)
	sqlc.querry("
insert into user_level_records(user_id,record_date,level_id,points,stars) values
({0},curdate(),{1},{2},{3})
;".format([gmd.user_id,get_index(),int(node.cur_time/node.max_time*points),0]))
	$pc/mc/play.grab_focus()


func play() -> void:
	if !Engine.is_editor_hint():
		get_tree().current_scene.get_node("cl").hide()
		var scnr:Scenario=load(scenario).instantiate()
		var scn:StaticBody2D=preload("res://mats/game_objs/level/lvl.tscn").instantiate()
		scn.get_node("player").dead.connect(
			(func(x:bool):scnr.emit_signal("level_ended",scnr))
		)
		scnr.level_ended.connect(_on_level_end)
		scn.add_child(scnr)
		get_tree().current_scene.get_node("world").add_child(scn)
