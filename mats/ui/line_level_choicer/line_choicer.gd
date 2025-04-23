class_name LineLevelChoicer extends PanelContainer
@export var training:=false
@export var track_name:String="test"
@export var authors_data:String="voidus"
@export_file("*.tscn;*.scn") var scenario:String="res://mats/game_objs/scenarios/scenario_test.tscn"
@export var recive_points:int=10
#var recived_points:int=0
#var collected:=0
var no_hit:=true
#var runned:=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$mc/cont/to_history.visible=!training
	$mc/cont/nm.text=str(track_name)+" - "+str(authors_data)
	#$mc/cont/collect.visible=!training
	#$mc/cont/points.visible=!training
	#$mc/cont/no_hit.visible=!training and runned and no_hit
#func _enter_tree() -> void:
	#upd_data()
#func upd_data():
	#var data:Dictionary=gmd.data.get(get_index(),{})
	#if not data.is_empty():
		#recived_points=data.points
		##$mc/cont/points/v.text=str(recived_points)
		#collected=data.collected
		##$mc/cont/collect/v.text=str(collected)
		#no_hit=data.no_hit
		##$mc/cont/no_hit.visible=no_hit

func _on_level_end(node:Scenario):
	node.get_parent().queue_free()
	var recived_points=int(node.cur_time/(node.starts_from+node.max_time)*recive_points)
	#$mc/cont/points/v.text=str(recived_points)
	#$mc/cont/collect/v.text=str(collected)
	#if snapped(node.cur_time,0.01)>=snapped(node.max_time+node.starts_from,0.01):
		#runned=true
		#$mc/cont/no_hit.visible=no_hit
	#sld.save_to_file(sld.file_path,true)
	if sqlc.CheckConnection():
		sqlc.query("
insert into user_level_records(user_id,record_date,level_id,points,collected,no_hit) values
({0}, NOW(), {1}, {2}, {3}, {4})
;".format([gmd.user_id,get_index(),recived_points,node.collected,no_hit]))
	get_tree().current_scene.upd_data()
	get_tree().current_scene.get_node("cl").show()
	$play.grab_focus()


func play() -> void:
	if !Engine.is_editor_hint():
		no_hit=true
		get_tree().current_scene.get_node("cl").hide()
		var scnr:Scenario=load(scenario).instantiate()
		var scn:StaticBody2D=preload("res://mats/game_objs/level/lvl.tscn").instantiate()
		scn.get_node("player/HurtBox").health_changed.connect(
			(func(h:float,d:float):if d<0:no_hit=false))
		scnr.level_ended.connect(_on_level_end)
		scn.add_child(scnr)
		get_tree().current_scene.get_node("world").add_child(scn)


func _on_save_loader_data_loaded() -> void:
	pass
	#$mc/cont/points/v.text=str(recived_points)
	#$mc/cont/no_hit.visible=no_hit and runned
