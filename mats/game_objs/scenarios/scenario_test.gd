class_name Scenario
extends Node
signal save_checkpoint_reached(id:int)
signal action_activated(track:int,time:float)
signal collection_event_activated(id:int,time:float)
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
@export var collection:InfoObject
var saved_player_pos:Vector2
var saved_collects:int
var saved_time:float=0
var saved_collected:=[]
var lvl_state:int=0
var asp:AudioPlayer
var cur_time:=0.0
var collected:=0

@onready var player=get_node_or_null("../player")
func get_size()->Vector2:
	return Vector2(
		ProjectSettings.get("display/window/size/viewport_width"),
		ProjectSettings.get("display/window/size/viewport_height")
	)
func get_rand_pos()->Vector2:
	return Vector2(
		fnc.rnd.randf_range(0,ProjectSettings.get("display/window/size/viewport_width")),
		fnc.rnd.randf_range(0,ProjectSettings.get("display/window/size/viewport_height"))
	)
func get_loop(value:float,max_value:float):
	return int(value/max_value)
func _ready() -> void:
	var fl:=HFlowContainer.new()
	fl.name="fl"
	fl.alignment=FlowContainer.ALIGNMENT_CENTER
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
	fl.add_child(bc)
	var stars_bc:=HBoxContainer.new()
	if collection!=null:
		for e in collection.times:
			var ch=CheckBox.new()
			ch.disabled=true
			stars_bc.add_child(ch)
	stars_bc.name="sbc"
	fl.add_child(stars_bc)
	add_child(fl)
	bc.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	fl.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	fnc.rnd.seed=fnc.rnd.randi()
	lvl_state=fnc.rnd.state
	action_activated.connect(_action_activated)
	level_ended.connect(_level_ended)
	level_started.connect(_level_started)
	if player!=null:
		saved_player_pos=player.global_position
		player.dead.connect(_player_dead)
	checkpoint_activated.connect(_checkpoint_activated)
	asp=$AudioPlayer
	if audio !=null:
		asp.asm=audio
		asp.time=max_time
	if auto_play_animation:
		$ap.play("track")
	if is_instance_valid(collection) and collection!=null:
		for e in range(collection.times.size()):
			var sz := get_size()
			var p:=Path2D.new()
			var fp:=PathFollow2D.new()
			fp.loop=false
			fp.rotates=false
			var c:=Curve2D.new()
			c.add_point(generate_random_border_point(sz))
			for i in range(fnc.rnd.randi_range(1,3)):
				c.add_point(get_rand_pos())
			c.add_point(generate_random_border_point(sz))
			p.curve=c
			var obj:=preload("res://mats/game_objs/collectable/collectable.tscn").instantiate()
			$paths.add_child(p)
			p.add_child(fp)
			fp.add_child(obj)
			saved_collected.append(0.0)
			obj.body_entered.connect((
			func(n):
				get_node("fl/sbc").get_child(collected).button_pressed=true
				collected+=1
				fp.progress_ratio=1
				))
	_post_ready()
	set_physics_process(!debug)
func _physics_process(delta: float) -> void:
	var can:=-1
	if checkpoints!=null:
		can=checkpoints.can(cur_time,max_time)
		if (can==0 and !infinite) or (can>=0 and infinite):
			save_checkpoint_reached.emit(can)
			saved_time=cur_time
			if player!=null:
				saved_player_pos=player.global_position
				saved_collects=collected
				for i in range($paths.get_child_count()):
					var e:PathFollow2D=$paths.get_child(i).get_child(0)
					saved_collected[i]=e.progress
				#print(saved_collected)
			#print("checkpoint activated: %d"%[at])
			emit_signal("checkpoint_activated")
	for at:int in range(action_times.size()):
		can=action_times[at].can(cur_time-starts_from,max_time)
		if (can==0 and !infinite) or (can>=0 and infinite):
			#print("activated: %d at %f"%[at,cur_time])
			emit_signal("action_activated",at,cur_time)
	if collection!=null:
		for collect:int in range(collection.times.size()):
			can=collection.can(cur_time-starts_from,max_time)
			if (can==0 and !infinite) or (can>=0 and infinite):
				#print("activated: %d at %f"%[collected,cur_time])
				emit_signal("collection_event_activated", collect, cur_time)
		for i in range($paths.get_child_count()):
			var e:Path2D=$paths.get_child(i)
			var pf:PathFollow2D=e.get_child(0)
			if cur_time>collection.times[i] and pf.progress_ratio<1.0:
				pf.progress+=200*delta
				
	cur_time+=delta
	if checkpoints!=null:
		get_node("fl/progress").get_child(checkpoints.played).value=cur_time
	if cur_time>=starts_from and cur_time<starts_from+0.1 and !asp.playing:
		emit_signal("level_started",self)
		asp.playing=true
		if !auto_play_animation:
			$ap.play("track")
	if cur_time>=starts_from+max_time:
		if !infinite:
			asp.playing=false
			set_physics_process(false)
			emit_signal("level_ended",self)
		
	_post_physics_process(delta)

func _post_ready():pass
func _post_physics_process(delta: float):pass
func _action_activated(track:int,time:float):pass
func _level_ended(node:Scenario):pass
func _level_started(node:Scenario):pass


func return_saved_data():
	pass
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
			return_saved_data()
			player.global_position=saved_player_pos
			collected=saved_collects
			for e in range(get_node("fl/sbc").get_child_count()):
				get_node("fl/sbc").get_child(e).button_pressed=e<collected
			$ap.seek(saved_time,true)
			fnc.rnd.state=lvl_state
			cur_time=saved_time
			for e:InfoObject in action_times:
				e.reset_to(saved_time,max_time)
			if collection!=null:
				collection.reset_to(saved_time,max_time)
				for i in range($paths.get_child_count()):
					var e:Path2D=$paths.get_child(i)
					var pf:PathFollow2D=e.get_child(0)
					pf.progress=saved_collected[i]
			await get_tree().process_frame
			get_node("../player/HurtBox").health=get_node("../player/HurtBox").max_health
	else:
		emit_signal("level_ended",self)
func _checkpoint_activated():pass

# Функция для генерации случайной точки за границей экрана
func generate_random_border_point(screen_size: Vector2, offset: float = 50) -> Vector2:
	var side := fnc.rnd.randi() % 4  # Случайно выбираем сторону

	match side:
		0:  # Верхняя сторона (за верхней границей)
			return Vector2(fnc.rnd.randf() * screen_size.x, -offset)
		1:  # Правая сторона (за правой границей)
			return Vector2(screen_size.x + offset, fnc.rnd.randf() * screen_size.y)
		2:  # Нижняя сторона (за нижней границей)
			return Vector2(fnc.rnd.randf() * screen_size.x, screen_size.y + offset)
		_:  # Левая сторона (за левой границей)
			return Vector2(-offset, fnc.rnd.randf() * screen_size.y)
