class_name HitBox
extends Area2D
signal deletion(node:HitBox)
@export var color:Color=Color(1,1,1,1)
@export var damage:float=1.0
@export var deletion_timer:float=0
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
		
func _physics_process(delta: float) -> void:
	_phy_proc(delta)
	queue_redraw()
func _phy_proc(delta:float):pass
func delete():pass
func _on_timer_timeout():
	emit_signal("deletion",self)
	delete()
	queue_free()
