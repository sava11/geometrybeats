class_name LineLevelChoicer extends PanelContainer
@export var training:=false
@export var track_name:String="test"
@export var authors_data:String="voidus"
@export_file("*.tscn;*.scn") var scenario:String="res://mats/game_objs/scenarios/scenario_test.tscn"
@export var recive_points:int=10

var hits:=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$mc/cont/to_history.visible=!training
	$mc/cont/nm.text=str(track_name)+" - "+str(authors_data)
	if not gmd.online:
		$mc/cont/to_history.hide()

func _on_level_end(node:Scenario):
	node.get_parent().queue_free()
	var recived_points=int(node.cur_time/(node.starts_from+node.max_time)*recive_points)

	if gmd.online and sqlc.CheckConnection():
		sqlc.query("
insert into user_level_records(user_login,record_date,level_id,points,collected,hits) values
('{0}', CURRENT_TIMESTAMP, {1}, {2}, {3}, {4})
;".format([gmd.user_login,get_index(),recived_points,node.collected,hits]))
	get_tree().current_scene.upd_data()
	if node.max_time+node.starts_from<=node.cur_time:
		get_tree().current_scene.get_node("level_end").hide()
		for e in get_tree().current_scene.get_node("world").get_children():
			e.queue_free()
		get_tree().current_scene.get_node(
			"level_end/Control/pc/mc/vbc/actions/retry").button_down.connect(play,4)
		get_tree().current_scene.get_node("level_end/Control/pc/mc/vbc/points/v").text=str(recived_points)
		get_tree().current_scene.get_node("level_end/Control/pc/mc/vbc/collected/v").text=str(node.collected)
		get_tree().current_scene.get_node(
			"level_end/Control/pc/mc/vbc/dmg/v").text=str(hits)
		get_tree().current_scene.get_node("level_end").show()
	get_tree().current_scene.get_node("cl").show()
	$mc/cont/play.grab_focus()


func play() -> void:
	if !Engine.is_editor_hint():
		hits=0
		get_tree().current_scene.get_node("cl").hide()
		var scnr:Scenario=load(scenario).instantiate()
		var scn:StaticBody2D=preload("res://mats/game_objs/level/lvl.tscn").instantiate()
		scn.get_node("player/HurtBox").health_changed.connect(
			(func(h:float,d:float):if d<0:hits+=1))
		scnr.level_ended.connect(_on_level_end)
		scn.add_child(scnr)
		get_tree().current_scene.get_node("world").add_child(scn)


func _on_save_loader_data_loaded() -> void:
	pass
	#$mc/cont/points/v.text=str(recived_points)
	#$mc/cont/no_hit.visible=no_hit and runned
