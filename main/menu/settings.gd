extends PanelContainer
signal apply_pressed
signal cancel_pressed
@export var data: Dictionary = {
	"fullsize": false,
	"sound": {"EFFECTS": 100, "MUSIC": 100}
}

func _ready() -> void:
	if not FileAccess.file_exists("settings.json"):
		sli.save_data("settings.json", data)
	else:
		data = sli.load_data("settings.json")
	set_data(data)

func set_data(d: Dictionary) -> void:	
	if d["fullsize"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	var music_slider :HSlider= get_node("mc/vbc/snd/c/music")
	music_slider.value = d["sound"]["MUSIC"]
	
	var effects_slider :HSlider= get_node("mc/vbc/snd/c/sound")
	effects_slider.value = d["sound"]["EFFECTS"]
	
	var full_screen_cb :CheckButton = get_node("mc/vbc/fscr/cb")
	full_screen_cb.button_pressed = d["fullsize"]


func music_value_changed(value: float) -> void:
	var music_slider = get_node("mc/vbc/snd/c/music") as HSlider
	var linear = music_slider.value / 100.0
	var db = linear_to_db(linear)
	data["sound"]["MUSIC"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func effects_value_changed(value: float) -> void:
	var effects_slider = get_node("mc/vbc/snd/c/sound") as HSlider
	var linear = effects_slider.value / 100.0
	var db = linear_to_db(linear)
	data["sound"]["EFFECTS"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), db)

func full_screen_toggled(toggled: bool) -> void:
	data["fullsize"] = toggled

func apply() -> void:
	set_data(data)
	sli.save_data("settings.json", data)
	apply_pressed.emit()

func back() -> void:
	if not FileAccess.file_exists("settings.json"):
		sli.save_data("settings.json", data)
	else:
		data = sli.load_data("settings.json")
	set_data(data)
	cancel_pressed.emit()
	#hide()
	#var anim_player = get_parent().get_node("anims") as AnimationPlayer
	#anim_player.play("settings", 0.3, -1, true)
