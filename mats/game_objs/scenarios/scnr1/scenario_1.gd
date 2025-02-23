extends Scenario
var pressed_btns=[]
var stage:=0
var step_time:=2.0
var time:=0.0
func _post_ready():pass
func _post_physics_process(delta: float):
	if stage==0:
		for e in ["ui_right","ui_left","ui_up","ui_down"]:
			if pressed_btns.find(e)==-1 and Input.is_action_just_pressed(e):
				pressed_btns.append(e)
		if pressed_btns.size()==4:
			time=0
			$tooltips.text="пробел - мгновенное перемещение\nс неуязвимостью ;)"
			stage+=1
	if stage==1:
		if Input.is_action_just_pressed("spirit"):
			$tooltips.text=""
			time=0
			stage+=1
	if stage==2:
		if time>=step_time:
			emit_signal("level_ended",self)
		time+=delta
func _action_activated(track:int,time:float):
	$act/PreSpawner.global_position=get_rand_pos()
	$act/PreSpawner.spawn=true
func _level_ended(node:Scenario):pass
