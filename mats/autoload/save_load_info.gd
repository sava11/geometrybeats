extends Node

static func save_data(path: String, data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()

static func load_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file.get_length() == 0:
		print("File is empty")
		file.close()
		return {}
	
	var content = JSON.parse_string(file.get_line())
	file.close()
	
	return content  # Returns a Godot Dictionary

func _ready() -> void:
	var dir_path = "saves"
	if not DirAccess.make_dir_absolute(dir_path):
		print("Failed to create directory")
