class_name HurtBox extends Area2D
signal invi_started
signal invi_ended
signal dead
signal revived
signal health_changed(value:float, delta:float)
signal max_health_changed(value:float, delta:float)
@export var tspeed:float=1.0
@export_flags_2d_physics() var flags:=13
@export var max_health:float=1: set=set_max_health
func set_max_health(value:float):
	emit_signal("max_health_changed",value,value-max_health)
	self.health=value*float(health)/float(max_health)
	max_health=value

var health:float=max_health: set=set_health
func set_health(value:float):
	var delta:=value-health
	emit_signal("health_changed",value,delta)
	if health<=0 and delta>0:
		alive=true
		emit_signal("revived")
	if is_node_ready():
		health=min(value,max_health)
	else:
		alive=true
		health=value
	if health<=0 and alive:
		alive=false
		emit_signal("dead")
		health=0
func restore_health():
	health=max_health
@onready var t:=Timer.new()
var alive:=false
var invincible=false:set=set_invincible
func set_invincible(v):
	invincible=v
	self.set_deferred("monitorable",!v)
	self.set_deferred("monitoring",!v)
	if invincible:
		emit_signal("invi_started")
	else:
		emit_signal("invi_ended")


func _ready():
	if !area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	emit_signal("max_health_changed",max_health,max_health)
	emit_signal("health_changed",health,health)
	add_child(t)
	t.timeout.connect(_on_Timer_timeout)
	if tspeed>0:
		t.wait_time=tspeed

func start_invincible(duration:float=1):
	if duration>0:
		self.invincible=true
		t.start(duration)

func _on_Timer_timeout():
	self.invincible=false


func _on_area_entered(area: HitBox) -> void:
	if health>0:
		var r=RayCast2D.new()
		r.name="ray_to_"+name
		area.add_child(r)
		r.global_position=area.global_position
		r.target_position=global_position-r.global_position
		r.global_rotation_degrees=0
		r.collision_mask=flags
		r.force_raycast_update()
		if r.get_collider()==get_parent() or r.get_collider()==null:
			health-=area.damage
			start_invincible(tspeed)
		r.queue_free()
