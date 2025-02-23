class_name Scenario
extends Node
signal action_activated(track:int,time:float)
signal level_ended(node:Scenario)
signal level_started(node:Scenario)
signal checkpoint_activated()
@export var debug:=false
@export var infinite:bool=false
@export var auto_play_animation:bool=false
@export var audio:AudioStream
@export_range(0,99,0.0001,"suffix:sec.","or_greater") var max_time:=1.0
@export_range(0,99,0.0001,"suffix:sec.","or_greater") var starts_from:float=0.0
@export var deaths_count:=3
@export var checkpoints:CheckpointObject
@export var action_times:Array[InfoObject]
@export var collect:Array
var saved_player_pos:Vector2
var saved_time:float=0
var lvl_state:int=0
var asp:AudioPlayer
var cur_time:=0.0
func get_size():
	return Vector2(
		ProjectSettings.get("display/window/size/viewport_width"),
		ProjectSettings.get("display/window/size/viewport_height")
	)
func get_rand_pos():
	return Vector2(
		fnc.rnd.randf_range(0,ProjectSettings.get("display/window/size/viewport_width")),
		fnc.rnd.randf_range(0,ProjectSettings.get("display/window/size/viewport_height"))
	)
func get_loop(value:float,max_value:float):
	return int(value/max_value)
func _ready() -> void:
	var bc:=HBoxContainer.new()
	var last_value:=0.0
	if checkpoints!=null:
		for e in range(checkpoints.times.size()+1):
			var pb:=ProgressBar.new()
			if e<checkpoints.times.size():
				pb.min_value=last_value
				pb.max_value=checkpoints.times[e]
			else:
				pb.min_value=last_value
				pb.max_value=max_time
			last_value=pb.max_value
			pb.custom_minimum_size.x=128
			bc.add_child(pb)
	bc.name="progress"
	add_child(bc)
	bc.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	fnc.rnd.seed=fnc.rnd.randi()
	lvl_state=fnc.rnd.state
	action_activated.connect(_action_activated)
	level_ended.connect(_level_ended)
	level_started.connect(_level_started)
	if get_node("../player")!=null:
		saved_player_pos=get_node("../player").global_position
		get_node("../player").dead.connect(_player_dead)
	checkpoint_activated.connect(_checkpoint_activated)
	asp=$AudioPlayer
	if audio !=null:
		asp.asm=audio
		asp.time=max_time
	if auto_play_animation:
		$ap.play("track")
	_post_ready()
	set_physics_process(!debug)
func _physics_process(delta: float) -> void:
	var can:=-1
	if checkpoints!=null:
		can=checkpoints.can(cur_time,max_time)
		if (can==0 and !infinite) or (can>=0 and infinite):
			saved_time=cur_time
			saved_player_pos=get_node("../player").global_position
			#print("checkpoint activated: %d"%[at])
			emit_signal("checkpoint_activated")
	for at:int in range(action_times.size()):
		can=action_times[at].can(cur_time-starts_from,max_time)
		if (can==0 and !infinite) or (can>=0 and infinite):
			#print("activated: %d at %f"%[at,cur_time])
			emit_signal("action_activated",at,cur_time)
	cur_time+=delta
	if checkpoints!=null:
		get_node("progress").get_child(checkpoints.played).value=cur_time
	if cur_time>=starts_from and cur_time<starts_from+0.1 and !asp.playing:
		emit_signal("level_started",self)
		print("started")
		asp.playing=true
		if !auto_play_animation:
			$ap.play("track")
	if cur_time>=starts_from+max_time:
		if !infinite:
			asp.playing=false
			print("ended ",cur_time)
			set_physics_process(false)
			emit_signal("level_ended",self)
	_post_physics_process(delta)

func _post_ready():pass
func _post_physics_process(delta: float):pass
func _action_activated(track:int,time:float):pass
func _level_ended(node:Scenario):pass
func _level_started(node:Scenario):pass

func _player_dead(v:bool):
	if deaths_count>0:
		if !v:
			deaths_count-=1
			print("dead")
			asp.stop()
			asp.play(saved_time,starts_from)
			for e in get_children():
				if e is MoveHitBox or e is HitBox:
					e.queue_free()
			get_node("../player").global_position=saved_player_pos
			$ap.seek(saved_time,true)
			fnc.rnd.state=lvl_state
			cur_time=saved_time
			for e:InfoObject in action_times:
				e.reset_to(saved_time,max_time)
			await get_tree().process_frame
			get_node("../player/HurtBox").health=get_node("../player/HurtBox").max_health
	else:
		emit_signal("level_ended",self)
func _checkpoint_activated():pass
