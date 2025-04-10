class_name HurtBox extends Area2D
signal pull_applyed(pull_power:Vector2)
signal invi_started
signal invi_ended
signal no_health
signal health_changed(value:float, delta:float)
signal max_health_changed(value:float, delta:float)
@export var command_id:=0
@export var max_health:float=1:
	set(value):
		var d:float=value-max_health
		self.health=snapped(value*self.health/max_health,0.001)
		max_health=value
		emit_signal("max_health_changed",max_health,d)
var health:float=max_health: 
	set(value):
		var d:float=value-health
		health=value
		if d<0:
			if tspeed>0:
				start_invi(tspeed)
			if health<=0:
				emit_signal("no_health")
				health=0
				t.stop()
		emit_signal("health_changed",value,d)
var t:Timer
@export var tspeed:float=1.0
var invi=false: 
	set(value):
		invi=value
		self.set_deferred("monitorable",!value)
		self.set_deferred("monitoring",!value)
		if invi:
			emit_signal("invi_started")
		else:
			emit_signal("invi_ended")
@onready var last_glb_pos:Vector2=global_position
@onready var glb_pos:Vector2=global_position
func _init() -> void:
	collision_layer=8
	collision_mask=8
func _ready():
	if !is_connected("area_exited",Callable(self,"_on_area_exited")):
		connect("area_exited",Callable(self,"_on_area_exited"))
	emit_signal("max_health_changed",max_health,0)
	emit_signal("health_changed",health,0)
	t=Timer.new()
	t.timeout.connect(self._on_Timer_timeout)
	add_child(t)
	if tspeed>0:
		t.wait_time=tspeed

func _physics_process(delta: float) -> void:
	if global_position!=last_glb_pos:
		glb_pos=global_position-last_glb_pos
		last_glb_pos=global_position

func start_invi(dir):
	self.invi=true
	t.start(dir)
func _on_Timer_timeout():
	self.invi=false

var exceptions:Array[HitBox]
func _on_area_entered(area:Area2D):
	if area is HitBox and command_id!=area.command_id and !(area in exceptions):
		var dmg=area.damage
		health-=dmg

func _on_area_exited(area: Area2D) -> void:
	if area is HitBox and area in exceptions:
		exceptions.remove_at(exceptions.find(area))
