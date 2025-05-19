extends Node
signal loaded_global_data()
signal saved_global_data()
var global_saved_data:={}
var file_path:="saves"
var file_name:="save"
const file_ext:="bak"
func get_file_path(file:String=file_name)->String:
	return file_path+file+"."+file_ext
func find_node(base_path:String)->Array[String]:
	for global_path in global_saved_data.keys():
		for sub_path in global_saved_data[global_path].keys():
			if sub_path==base_path:
				return [global_path,sub_path]
	return []
func local_save()->void:
	for e in global_saved_data.keys():
		if get_node_or_null(e)!=null:
			global_saved_data.merge(get_node(e).save_data(),true)
	emit_signal("saved_global_data")
func local_load()->void:
	for e in global_saved_data.keys():
		if get_node_or_null(e)!=null:
			print(e)
			get_node(e).load_data(global_saved_data[e])
	emit_signal("loaded_global_data")
func save_to_file(path:String,json:bool=false)->void:
	local_save()
	set_to_file(global_saved_data,path,json)
func load_from_file(path:String,json:bool=false)->void:
	if DirAccess.dir_exists_absolute(path):
		global_saved_data=get_from_file(path,json)
		local_load()
func set_to_file(d: Dictionary, path: String = file_path + "/" + file_name + "." + file_ext, json: bool = false) -> void:
	
	# Получаем директорию из пути к файлу
	var dir_path := path.get_base_dir()
	
	# Проверяем и создаём директорию
	if !DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	# Открываем файл
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("Не удалось открыть файл для записи: " + path)
		return

	if !json:
		var bytes := var_to_bytes(d)
		f.store_buffer(bytes)
	else:
		f.store_line(JSON.stringify(d))
	
	f.close()
	print("saved")

func get_from_file(path:String=file_path+"/"+file_name+"."+file_ext,json:bool=false)->Dictionary:
	if FileAccess.file_exists(path):
		var f:=FileAccess.open(path,FileAccess.READ)
		var d:Dictionary={}
		if !json:
			var bytes:=f.get_buffer(f.get_length())
			d=bytes_to_var(bytes)
		else:
			d=JSON.parse_string(f.get_as_text())
		f.close()
		print("loaded: ",d)
		return d
	print("err load")
	return {}
