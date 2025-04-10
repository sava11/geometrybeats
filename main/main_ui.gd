extends Node
@onready var down_panel:=$cl/ui/pc/mc/hbc
@export var current_level:UILevel


func _ready() -> void:
	var mx_size:=Vector2.ZERO
	if current_level!=null:
		current_level.get_node("pc/mc/play").grab_focus()
	sld.load_from_file(sld.file_path,true)
	for e in $cl/ui/mc2/sc/cont.get_children():
		e.upd_data()
		
	var last_runned:=0
	for e in $cl/ui/mc2/sc/cont.get_children():
		if e.runned:
			last_runned=e.get_index()
var points:int=0
var stars:int=0
func upd_data()->void:
	points=0
	stars=0
	for e in $cl/ui/mc2/sc/cont.get_children():
		points += e.recived_points
		stars += e.collected
func _physics_process(delta: float) -> void:
	upd_data()
	if Input.is_action_just_pressed("esc") and $world.get_child_count()>0:
		get_tree().paused=!get_tree().paused
		$pause.visible=get_tree().paused
	down_panel.get_node("un").text=str(gmd.user_name)
	down_panel.get_node("pnts").text=str(points)
	down_panel.get_node("strs_c/strs").text=str(stars)


func _on_exit_button_down() -> void:
	gmd.user_id=0
	gmd.user_name=""
	get_tree().change_scene_to_file("res://main/menu/login.tscn")


func _on_exit_2_button_down() -> void:
	get_tree().quit()


func _on_cnt_button_down() -> void:
	get_tree().paused=false
	$pause.visible=get_tree().paused


func _on_to_lvls_button_down() -> void:
	if $world.get_child_count()>0:
		$world.get_child(0).get_node("scenario").level_ended.emit(
			$world.get_child(0).get_node("scenario"))
	get_tree().paused=false
	$pause.visible=get_tree().paused
