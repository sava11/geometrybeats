extends Scenario
var step:=0
var step_time:=2.0
var time:=0.0
func _post_ready():pass
func _post_physics_process(delta: float):pass
func _action_activated(track:int,time:float):
	if track==0:
		var smn:Summoner=$act/Summoner
		#var pl=get_parent().get_node("player")
		#if pl!=null:
			#pl.globlal_position
		#else:
			#var glb_ang:=smn.angle+smn.global_rotation_degrees
			#var start_point:=smn.global_position+Vector2(
				#cos(deg_to_rad(glb_ang)),sin(deg_to_rad(glb_ang)))*smn.line_size/(1+int(smn.centered))
			#var end_point:=smn.global_position+Vector2(
				#cos(deg_to_rad(glb_ang-180)),sin(deg_to_rad(glb_ang-180)))*smn.line_size/(1+int(smn.centered))
		var t=[[Vector2(0,0),0],[Vector2(1,1),-180],[Vector2(1,0),-180],[Vector2(0,1),0]]
		step=(step+1+fnc._with_chance_ulti([0.8,0.2]))%t.size()
		var p=t[step]
		
		smn.global_position=p[0]*get_size()#get_rand_pos()
		if p[0].y==0:
			smn.global_position.y+=smn.line_size/2
		if p[0].y==1:
			smn.global_position.y-=smn.line_size/2
		smn.rotation_degrees=p[1]
		print(smn.global_position)
			#smn.rotation_degrees
		
		smn.spawn=true
func _level_ended(node:Scenario):pass
