class_name AudioPlayer extends Node2D
@export_range(0,100,0.001,"suffix:sec","or_greater") var time:float=1
@export var attenuation:float=1
var sec_time=0
@export var asm:AudioStream
enum t{all, d2, d3,}
@export var exto:t
@export var busName:String="Master"
@export var volume_db_2_3_d:float=0
@export var auto_play:bool=false
var playing:=false
var temp_time_to_apply:=0.0
func _ready() -> void:
	if auto_play:
		play()
func _process(delta):
	#print(playing)
	for e in get_children():
		if e.playing==false:
			e.queue_free()
	if playing==true and time>0 and (sec_time>=time or (get_child_count()==0 and sec_time>=0)):
		var asp=null
		if exto==t.d2:
			asp = AudioStreamPlayer2D.new()
			asp.volume_db=volume_db_2_3_d
		if exto==t.all:
			asp = AudioStreamPlayer.new()
			asp.volume_db=volume_db_2_3_d
		if exto==t.d3:
			asp = AudioStreamPlayer3D.new()
		add_child(asp)
		asp.stream=asm
		asp.bus=busName
		asp.play(clamp(temp_time_to_apply,0,asm.get_length()))
		temp_time_to_apply=0
		asp.set_process(true)
		if not asp is AudioStreamPlayer:
			asp.attenuation=attenuation
		sec_time=0
	
	if playing==false:
		for e in get_children():
			e.queue_free()
	sec_time+=delta
func play(time:float=sec_time,add_time:=0.0):
	playing=true
	for e in get_children():
		e.queue_free()
	sec_time=time-add_time
	temp_time_to_apply=time-add_time
func is_playing()->bool:
	return get_child_count()>0 and playing
func stop():
	playing=false
	for e in get_children():
		e.queue_free()
