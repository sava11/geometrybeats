class_name Scenario
extends Node
signal save_checkpoint_reached(id:int)
signal action_activated(track:int,time:float)
signal collection_event_activated(id:int,time:float)
signal level_ended(node:Scenario)
signal level_started(node:Scenario)
signal checkpoint_activated()
signal track_started()
@export var debug:=false
@export var save_data:Array[node_data]
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
var saved_data:Dictionary

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
	fl.z_index=999
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
	for dt in save_data:
		var n=get_node(dt.node)
		if is_instance_valid(n):
			var d:Dictionary
			for e in dt.data:
				d.merge( {e:n.get(e)}, true )
			saved_data.merge({str(n.get_path()):d}, true)
	_spawn_collectables()
	_post_ready()
	set_physics_process(!debug)

func _spawn_collectables():
	if not is_instance_valid(collection):
		return

	for e in collection.times.size():
		var sz = get_size()
		
		# Создаём Path2D и PathFollow2D
		var path = Path2D.new()
		$paths.add_child(path)
		var follow = PathFollow2D.new()
		follow.loop = false
		follow.rotates = false
		path.add_child(follow)
		
		# Генерируем список ключевых точек (начало → 1–3 внутренних → конец)
		var pts: Array[Vector2] = []
		pts.append(generate_random_border_point(sz))
		for i in range(fnc.rnd.randi_range(1, 3)):
			pts.append(get_rand_pos())
		pts.append(generate_random_border_point(sz))
		
		path.curve = _generate_smooth_curve(pts)
		
		# Инстанцируем объект и цепляем к PathFollow2D
		var obj = preload("res://mats/game_objs/collectable/collectable.tscn").instantiate()
		follow.add_child(obj)
		saved_collected.append(0.0)
		
		# Подписываемся на сигнал
		obj.body_entered.connect(func(_body):
			get_node("fl/sbc").get_child(collected).button_pressed = true
			collected += 1
			follow.progress_ratio = 1
		)

func _generate_smooth_curve(points: Array[Vector2]) -> Curve2D:
	var curve = Curve2D.new()
	var n = points.size()
	
	for i in range(n):
		var p_prev = points[max(i - 1, 0)]
		var p_curr = points[i]
		var p_next = points[min(i + 1, n - 1)]
		
		var dir_in = (p_curr - p_prev).normalized()
		var dir_out = (p_next - p_curr).normalized()
		
		var tangent = (dir_in + dir_out).normalized()
		var length_in = (p_curr - p_prev).length() * 0.25
		var length_out = (p_next - p_curr).length() * 0.25
		
		var in_tangent = -tangent * length_in
		var out_tangent = tangent * length_out
		
		curve.add_point(p_curr, in_tangent, out_tangent)
	
	return curve

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
				for dt in save_data:
					var n=get_node(dt.node)
					if is_instance_valid(n):
						var d:Dictionary
						for e in dt.data:
							d.merge( {e:n.get(e)}, true )
						saved_data.merge({str(n.get_path()):d})
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
				pf.progress+=180*delta
				
	cur_time+=delta
	if checkpoints!=null:
		get_node("fl/progress").get_child(checkpoints.played).value=cur_time
	if cur_time>=starts_from and cur_time<starts_from+0.1 and !asp.playing:
		emit_signal("level_started",self)
		asp.playing=true
		if !auto_play_animation:
			$ap.play("track")
			track_started.emit()
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
	asp.stop()
	get_tree().create_timer(1).timeout.connect(
	func():
		if deaths_count>0:
			if !v:
				deaths_count-=1
				print("dead")
				asp.play(saved_time,starts_from)
				for e in get_children():
					if e is MoveHitBox or e is HitBox:
						e.queue_free()
				return_saved_data()
				for dt in save_data:
					var n=get_node(dt.node)
					if is_instance_valid(n):
						for e in dt.data:
							n.set(e,saved_data[str(n.get_path())][e])
							n.set_deferred(e,saved_data[str(n.get_path())][e])
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
				get_node("../player/HurtBox").restore_health()
		else:
			level_ended.emit(self)
	)
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
