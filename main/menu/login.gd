extends Control
var ctx = HashingContext.new()
func _ready() -> void:
	$pc/mc/vbc/user.grab_focus()
	# Process results
func _on_log_button_down() -> void:
	if sqlc.CheckConnection():
		if not ( $pc/mc/vbc/user.text=="" or 
			$pc/mc/vbc/hbc/log.text==""):
			ctx.start(HashingContext.HASH_SHA1)
			ctx.update($pc/mc/vbc/pass.text.to_utf8_buffer())
			var ps=ctx.finish().hex_encode()
			var arr:Array=sqlc.query("
		select login from users where login=\"{0}\" and password=\"{1}\"".
			format([$pc/mc/vbc/user.text,ps]))
			if !arr.is_empty():
				arr=arr[0]
				gmd.user_login=arr[0]
				arr=sqlc.query("
		SELECT 
			level_id, 
			points, 
			collected,
			no_hit
		FROM user_level_records 
		WHERE user_login = '{0}'
		ORDER BY record_date DESC
		LIMIT 1;".format([gmd.user_login]))
			#if arr.size()>0:
				#for e in arr:
					#gmd.data.merge({
						#int(e[0]):{
							#"points":int(e[1]),
							#"collected":int(e[2]),
							#"no_hit":e[3]
							#}
						#})
				gmd.online=true
				get_tree().change_scene_to_file("res://main/main_ui.tscn")
			else:
				print("data isn't exists")
				$err.text="нет совпадений"
		else:
			$err.text="введите логин и пароль"
	else:
		print("database is offline")
		$err.text="нет доступа к базе данных"

func _on_exit_button_down() -> void:
	get_tree().quit()



func _on_just_play_button_down() -> void:
	get_tree().change_scene_to_file("res://main/main_ui.tscn")

func _on_settings_button_pressed() -> void:
	$settings.hide()
	$to_settings.show()
	$to_settings.grab_focus()


func _on_to_settings_button_down() -> void:
	$settings.show()
	$to_settings.hide()
	$settings/mc/vbc/hbc/bc.grab_focus()
