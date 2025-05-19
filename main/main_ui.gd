extends Node
@onready var down_panel:=$cl/ui/pc/mc/hbc
@onready var history_item_cont:=$cl/history/sc/cont


func _ready() -> void:
	var mx_size:=Vector2.ZERO
	#down_panel.get_node("un").text=gmd.user_login
	for e in $cl/ui/mc/sc/cont.get_children():
		e.get_node("mc/cont/to_history").button_down.connect(_to_history.bind(e.get_index()))
	upd_data()


func upd_data()->void:
	var points:=0
	var stars:=0
	#var hits:=0
	if gmd.online and sqlc.CheckConnection():
		var temp_array=sqlc.query("SELECT
	level_id,
	MAX(points)		AS max_points,
	MAX(collected)	AS max_collected
FROM user_level_records
WHERE user_login = '{0}'
GROUP BY level_id
ORDER BY level_id;".format([gmd.user_login]))
#--,
	#--MIN(hits)		AS min_hits
		if not gmd.online:
			$cl/ui/pc/mc/hbc/hbc/exit.show()
			$cl/ui/pc/mc/hbc/pnts.hide()
			$cl/ui/pc/mc/hbc/strs_c.hide()
			#$cl/ui/pc/mc/hbc/no_hits_c.hide()
		if temp_array.size()>0:
			for element in temp_array:
				points+=int(element[1])
				stars+=int(element[2])
				#hits+=int(element[3])
	down_panel.get_node("pnts").text=str(points)
	down_panel.get_node("strs_c/strs").text=str(stars)
	#down_panel.get_node("no_hits_c/no_hits").text=str(hits)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("esc") and $world.get_child_count()>0:
		get_tree().paused=!get_tree().paused
		$pause.visible=get_tree().paused


func _on_exit_button_down() -> void:
	gmd.user_login=""
	#gmd.user_name=""
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

func _to_history(id:int):
	for e in history_item_cont.get_children():
		e.queue_free()
	if gmd.online and sqlc.CheckConnection():
		var history:Array=sqlc.query("
CALL get_user_level_attempts('{0}', {1}, 'record_id DESC')
;".format([gmd.user_login,id]))
		for i in range(history.size()):
			var e=history[i]
			var item:=preload("res://mats/ui/history_item/history_item.tscn").instantiate()
			item.get_node("mc/hbc/number").text=str(i)
			item.get_node("mc/hbc/points").text=str(e[0])
			item.get_node("mc/hbc/collected").text=str(e[1])
			item.get_node("mc/hbc/no_hit").text=str(e[2])
			var times:Array=e[3][1].split(":")
			times.remove_at(2)
			var time=times[0]
			for s in range(1,times.size()):
				time+=":"+times[s]
			item.get_node("mc/hbc/date").text=str(e[3][0]) + " " + time
			history_item_cont.add_child(item)
	$cl/history.show()
	$cl/ui.hide()

func _on_back_from_history_button_down() -> void:
	$cl/history.hide()
	$cl/ui.show()


func exit_to_level_menu() -> void:
	$level_end.hide()
	$cl.show()


func _on_settings_apply_pressed() -> void:
	$settings.hide()


func _on_to_settings_button_down() -> void:
	$settings.show()
