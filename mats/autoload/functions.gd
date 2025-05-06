@tool
extends Node
var rnd:=RandomNumberGenerator.new()
func i_search(array,i):
	var inte=0
	for k in array:
		if k==i:
			return inte
		inte+=1
	return -1
var already_paused:int=0
func set_pause(paused:bool=true):
	already_paused+=-1+2*int(paused)
	already_paused=clamp(already_paused,0,999999)
	get_tree().paused=already_paused>0
	PhysicsServer2D.set_active(true)
func angle(V:Vector2)->float:
	return rad_to_deg(-atan2(-V.y,V.x))
func _rotate_vec(vec:Vector2,ang:float)->Vector2:
	return move(rad_to_deg(angle(vec))+ang)*_sqrt(vec)
## returns distance
func _sqrt(v:Vector2)->float:
	return sqrt(v.x*v.x+v.y*v.y)
## returns vector size
func sqrtV(v:Vector2)->Vector2:
	return Vector2(sqrt(v.x),sqrt(v.y))
func move(ang):
	return Vector2(cos(deg_to_rad(ang)),sin(deg_to_rad(ang)))

func sum(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum

func _with_chance_ulti(chances=[0.5,0.5])->int:
	var sum=sum(chances)
	var cur_value=rnd.randf_range(0,sum)
	var prefix:float=0
	if sum>0:
		for e in range(chances.size()):
			if cur_value>=prefix and cur_value<prefix+chances[e]:
				return e
			prefix+=chances[e]
	return -1

#func _ready() -> void:
	#rnd.seed=0

signal darked(result:bool)
func set_dark(r:bool=true,time:float=1):
	var cl:CanvasLayer=get_tree().root.get_node_or_null("darkness_bg")
	if r and cl==null:
		cl=CanvasLayer.new()
		cl.layer=3
		cl.name="darkness_bg"
		var cr=ColorRect.new()
		cr.name="darkness"
		cr.set_anchors_preset(Control.PRESET_FULL_RECT)
		cr.color=Color(0,0,0,0)
		cl.add_child(cr)
		get_tree().root.add_child(cl)
		var tween = get_tree().create_tween().bind_node(cr).chain().set_trans(Tween.TRANS_EXPO)
		tween.tween_property(cr, "color", Color(0,0,0,1), time)
		tween.tween_callback((func():emit_signal("darked",r)))
	elif cl!=null:
		var cr=cl.get_node("darkness")
		cr.color=Color(0,0,0,1)
		var tween = get_tree().create_tween().bind_node(cr).chain().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(cr, "color", Color(0,0,0,0), time)
		tween.tween_callback((func():
			emit_signal("darked",r)
			cl.queue_free()))
