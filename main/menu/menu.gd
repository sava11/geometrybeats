extends Control
func _ready() -> void:pass


func _on_button_button_down() -> void:
	var arr:Array=sqlc.query("
select id,name from users where login=\"{0}\" and password=\"{1}\"".format([$pc/mc/vbc/uname.text,$pc/mc/vbc/upass.text]))
	if !arr.is_empty():
		arr=arr[0]
		gmd.user_id=arr[0]
		gmd.user_name=arr[1]
		arr=sqlc.query("
SELECT level_id, MAX(points) AS max_points
FROM user_level_records where user_id={0}
GROUP BY level_id;".format([gmd.user_id]))
		for e in arr:
			gmd.data.merge({e[0]:e[1]})
		get_tree().change_scene_to_file("res://main/main_ui.tscn")
