class_name HitBox
extends Area2D
signal deletion(node:HitBox)
signal local_event
@export var color:Color=Color(0.75,0,75,1)
@export var damage:float=1.0
@export_range(0, 1, 0.001) var enabled: float = 1.0
@export_range(0, 1, 0.001) var hited: float = 0.95
@export var oneshout:=false
@export var curve:Curve
@export var deletion_timer:float=0
@export var local_event_time:float=0
var evented:=false
var new_polygons:Array[PackedVector2Array]
func _init() -> void:
	collision_layer=8
	collision_mask=8
func _post_ready():pass
func _ready() -> void:
	if deletion_timer>0:
		var t=Timer.new()
		t.timeout.connect(self._on_timer_timeout)
		add_child(t)
		t.start(deletion_timer)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	if oneshout:
		color.a=0
		enabled=false
		if time>=local_event_time and !evented:
			emit_signal("local_event")
			evented=true
	_post_ready()
func _draw() -> void:
	if is_node_ready():
		for e in new_polygons:
			draw_colored_polygon(e, Color(color.r,color.g,color.b,0.25))
		for n in get_children():
			if n is CollisionShape2D:
				if n.shape is RectangleShape2D:
					var s: RectangleShape2D = n.shape
					draw_rect(Rect2(-s.size / 2+n.position, s.size), color, true)
				elif n.shape is CircleShape2D:
					var s: CircleShape2D = n.shape
					draw_circle(n.position, s.radius, color)
				elif n.shape is CapsuleShape2D:
					var s: CapsuleShape2D = n.shape
					draw_circle(Vector2(0, -s.height / 2 + s.radius)+n.position, s.radius, color)
					draw_circle(Vector2(0, s.height / 2 - s.radius)+n.position, s.radius, color)
					draw_rect(Rect2(Vector2(-s.radius, -s.height / 2 + s.radius)+n.position, 
					Vector2(s.radius * 2, s.height - s.radius * 2)), color, true)
			elif n is CollisionPolygon2D:
				draw_colored_polygon(n.polygon, color)
var time:=0.0
func _physics_process(delta: float) -> void:
	if oneshout and curve.point_count>0:
		enabled=curve.sample_baked(time/deletion_timer)
		if time>=local_event_time and !evented:
			local_event.emit()
			evented=true
		time+=delta
	color.a = enabled
	set_deferred("monitorable", enabled >= hited)
	set_deferred("monitoring", enabled >= hited)
	queue_redraw()
	_phy_proc(delta)

func _phy_proc(delta:float) -> void:pass
func delete():pass
func _on_timer_timeout():
	emit_signal("deletion",self)
	delete()
	queue_free()
