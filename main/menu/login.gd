extends Control
var ctx = HashingContext.new()

func _on_log_button_down() -> void:
	ctx.start(HashingContext.HASH_SHA1)
	ctx.update($pc/mc/vbc/pass.text.to_utf8_buffer())
	var ps=ctx.finish().hex_encode()
	var arr:Array=sqlc.querry("
select id,login from users where login=\"{0}\" and password=\"{1}\"".format([$pc/mc/vbc/user.text,ps]))
	print(arr)
	if !arr.is_empty():
		
		arr=arr[0]
		gmd.user_id=arr[0]
		gmd.user_name=arr[1]
		arr=sqlc.querry("
SELECT 
	level_id, 
	points, 
	collected,
	no_hit
FROM user_level_records 
WHERE user_id = {0}
ORDER BY record_date DESC
LIMIT 1;".format([gmd.user_id]))
		for e in arr:
			gmd.data.merge({
				e[0]:{
					"points":e[1],
					"collected":e[2],
					"no_hit":e[3]
					}
				})
		get_tree().change_scene_to_file("res://main/main_ui.tscn")
