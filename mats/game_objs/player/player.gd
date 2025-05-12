class_name Player
extends CharacterBody2D

signal dead(alive: bool)

@export_range(1, 1000, 1, "or_greater") var speed := 500.0
@export_range(1, 1000, 1, "or_greater") var jump := 500.0
@export_range(1, 1000, 1, "or_greater") var acceleration := 2200.0
@export_range(0.001, 1000, 0.001, "or_greater") var spirit_timer := 0.5
@export_range(1, 1000, 1, "or_greater") var spirit_speed := 700.0
@export_range(1, 1000, 1, "or_greater") var spirit_acceleration := 2500.0
@export var physical_body := true:
	set(v):
		physical_body=v
		if v and not $HurtBox.invincible:
			$skin.color.a = 1
		else:
			$skin.color.a = 0.5
var alive := true
var spirit_timer_temp := 0.0
var last_mvd:=Vector2.RIGHT

func _ready() -> void:
	var col:=$collision.duplicate()
	$HurtBox.add_child(col)
	$skin.size = col.shape.size
	$skin.position = -col.shape.size / 2
	$inv.max_value=$HurtBox.tspeed

func _physics_process(delta: float) -> void:
	if alive:
		$inv.value=$HurtBox.t.time_left
		var mvd = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)
		if mvd!=Vector2.ZERO:
			last_mvd=mvd
		if Input.is_action_just_pressed("spirit"):
			physical_body = false
			velocity=last_mvd * spirit_speed
			$HurtBox.set_deferred("monitorable", physical_body)
			$HurtBox.set_deferred("monitoring", physical_body)
		if !physical_body:
			spirit_timer_temp += delta
			if spirit_timer_temp >= spirit_timer:
				spirit_timer_temp = 0
				physical_body = true
				velocity = mvd * speed
				$HurtBox.set_deferred("monitorable", physical_body)
				$HurtBox.set_deferred("monitoring", physical_body)
			else:
				velocity = velocity.move_toward(last_mvd.normalized() * spirit_speed, spirit_acceleration * delta)
		else:
			velocity = velocity.move_toward(mvd.normalized() * speed, acceleration * delta)
		move_and_slide()

func hited(v:float,d:float) -> void:
	alive = v>0
	$skin.material.set_deferred("shader_parameter/sector", v/$HurtBox.max_health)
	if d<0 and alive:
		$asp.play()
		velocity+=fnc.move(randi_range(-180,180))*1000
	else:
		$inv.visible=false
		$skin.color.a = 1
	if !alive:
		emit_signal("dead", v>0)
	#$asp.stream = load("res://mats/sounds/twrauw.wav")
	#$asp.play()


func _on_hurt_box_invi_started() -> void:
	$inv.visible=true
	$skin.color.a = 0.5


func _on_hurt_box_invi_ended() -> void:
	$inv.visible=false
	$skin.color.a = 1
